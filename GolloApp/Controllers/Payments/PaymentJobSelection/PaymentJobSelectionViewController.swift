//
//  PaymentJobSelectionViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 3/1/24.
//

import RxSwift
import UIKit

protocol PaymentJobSelectionDelegate: AnyObject {
    func continuePayment(with date: ResponseDate, hour: ResponseHours)
}

class PaymentJobSelectionViewController: UIViewController {
    
    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var hourCollectionView: UICollectionView!
    @IBOutlet weak var continuePaymentButton: UIButton!
    
    let bag = DisposeBag()
    let viewModel: PaymentJobSelectionViewModel
    let delegate: PaymentJobSelectionDelegate
    let dateFormatter = DateFormatter()
    
    init(viewModel: PaymentJobSelectionViewModel, delegate: PaymentJobSelectionDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: "PaymentJobSelectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureRx()
    }
    
    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }
    
    // MARK: - Function
    func configureViews() {
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        
        popUpView.layer.cornerRadius = 15
        continuePaymentButton.layer.masksToBounds = true
        continuePaymentButton.layer.cornerRadius = 10
        continuePaymentButton.layoutIfNeeded()
    }

    func configureRx() {
        continuePaymentButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if let date = self.viewModel.dateSelected, let hour = self.viewModel.hourSelected {
                    self.dismiss(animated: true) {
                        self.delegate.continuePayment(with: date, hour: hour)
                    }
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar fecha y hora")
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchAvailableSlots() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchSlots()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.viewModel.slotAvailabilities = response
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEE"
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMM"
                let dayNumberFormatter = DateFormatter()
                dayNumberFormatter.dateFormat = "dd"
                
                let dates = response.map({ slot -> ResponseDate in
                    let scheduleDate = self.dateFormatter.date(from: slot.from ?? "") ?? Date()
                    var dateComponents = DateComponents()
                    dateComponents.year = Calendar.current.component(.year, from: scheduleDate)
                    dateComponents.month = Calendar.current.component(.month, from: scheduleDate)
                    dateComponents.day = Calendar.current.component(.day, from: scheduleDate)
                    dateComponents.hour = 0
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    let date = NSCalendar.current.date(from: dateComponents)!
                    
                    return ResponseDate(
                        day: dayFormatter.string(from: date).capitalized,
                        month: monthFormatter.string(from: date),
                        numberDay: dayNumberFormatter.string(from: date),
                        slotDate: date
                    )
                }).unique(map: { $0.slotDate })
                
                if !dates.isEmpty {
                    self.viewModel.responseDate = dates.unique { $0.day ?? "" }
                    self.dateCollectionView.reloadData()
                }
                
                self.view.activityStopAnimatingFull()
            })
            .disposed(by: bag)
    }
}

extension PaymentJobSelectionViewController: UICollectionViewDelegate,
                                      UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.dateCollectionView {
            return viewModel.responseDate.count
        } else {
            return viewModel.hoursAvailabilities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.dateCollectionView {
            return CGSize(width: 80, height: 90)
        } else {
            return CGSize(width: 140, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.dateCollectionView {
            return getDatePickingCell(collectionView, cellForItemAt: indexPath)
        } else {
            return getHourPickingCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func getDatePickingCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DatePickingCollectionViewCell", for: indexPath) as! DatePickingCollectionViewCell
        cell.setDateData(with: viewModel.responseDate[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func getHourPickingCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourPickingCollectionViewCell", for: indexPath) as! HourPickingCollectionViewCell
        cell.setHourData(with: viewModel.hoursAvailabilities[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension PaymentJobSelectionViewController: DatePickingCellDelegate {
    func dateCell(_ productCollectionViewCell: DatePickingCollectionViewCell, willSelectDateWith data: ResponseDate?) {
        for i in 0..<viewModel.responseDate.count {
            if viewModel.responseDate[i] == data {
                viewModel.responseDate[i].selected = !(data?.selected ?? false)
            } else {
                viewModel.responseDate[i].selected = false
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "a"
        
        let hoursAvailabilities = viewModel.slotAvailabilities.filter { slot in
            let calendar = Calendar.current
            let selectedDate = self.dateFormatter.date(from: slot.from ?? "") ?? Date()
            var dateComponents = DateComponents()
            dateComponents.year = Calendar.current.component(.year, from: selectedDate)
            dateComponents.month = Calendar.current.component(.month, from: selectedDate)
            dateComponents.day = Calendar.current.component(.day, from: selectedDate)
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            let date = calendar.date(from: dateComponents)!

            return date == data?.slotDate
        }.map { slot in
            let fromSelectedDate = self.dateFormatter.date(from: slot.from ?? "") ?? Date()
            let toSelectedDate = self.dateFormatter.date(from: slot.to ?? "") ?? Date()

            let fromDate = dateFormatter.string(from: fromSelectedDate)
            let fromHour = hourFormatter.string(from: fromSelectedDate)
            let toDate = dateFormatter.string(from: toSelectedDate)
            let toHour = hourFormatter.string(from: toSelectedDate)

            return ResponseHours(
                idSlot: slot.id,
                fromDate: fromDate,
                fromHour: fromHour,
                toDate: toDate,
                toHour: toHour
            )
        }
        
        viewModel.hoursAvailabilities = hoursAvailabilities
        viewModel.dateSelected = data
        viewModel.hourSelected = nil
        dateCollectionView.reloadData()
        
        if viewModel.responseDate.filter({ $0.selected == true }).isEmpty {
            viewModel.dateSelected = nil
            self.hourLabel.isHidden = true
            self.hourCollectionView.isHidden = true
        } else {
            if !hoursAvailabilities.isEmpty {
                self.hourLabel.isHidden = false
                self.hourCollectionView.isHidden = false
                self.hourCollectionView.reloadData()
            } else {
                self.hourLabel.isHidden = true
                self.hourCollectionView.isHidden = true
            }
        }
    }
}

extension PaymentJobSelectionViewController: HourPickingCellDelegate {
    func hourCell(_ productCollectionViewCell: HourPickingCollectionViewCell, willSelectHourWith data: ResponseHours?) {
        for i in 0..<viewModel.hoursAvailabilities.count {
            if viewModel.hoursAvailabilities[i] == data {
                viewModel.hoursAvailabilities[i].selected = !(data?.selected ?? false)
            } else {
                viewModel.hoursAvailabilities[i].selected = false
            }
        }
        
        viewModel.hourSelected = data
        self.hourCollectionView.reloadData()
        
        if self.viewModel.hoursAvailabilities.filter({ $0.selected == true }).isEmpty {
            viewModel.hourSelected = nil
        }
    }
}
