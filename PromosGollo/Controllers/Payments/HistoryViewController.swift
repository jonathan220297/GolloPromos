//
//  HistoryViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {

    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    let dateFormatter = DateFormatter()
    var imagePicker = UIImagePickerController()

    private var datePickerFrom: UIDatePicker?
    private var datePickerTo: UIDatePicker?

    lazy var viewModel: HistoryViewModel = {
        return HistoryViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Date Picker
        datePickerFrom = UIDatePicker()
        datePickerFrom?.datePickerMode = .date
        datePickerFrom?.locale = .current
        if #available(iOS 14, *) {
            datePickerFrom?.preferredDatePickerStyle = .wheels
            datePickerFrom?.sizeToFit()
        }
        datePickerFrom?.addTarget(self, action: #selector(HistoryViewController.dateChangeFrom(datePicker:)), for: .valueChanged)

        datePickerTo = UIDatePicker()
        datePickerTo?.datePickerMode = .date
        if #available(iOS 14, *) {
            datePickerTo?.preferredDatePickerStyle = .wheels
            datePickerTo?.sizeToFit()
        }
        datePickerTo?.addTarget(self, action: #selector(HistoryViewController.dateChangeTo(datePicker:)), for: .valueChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HistoryViewController.viewTapped(gestureRecognized:)))
        view.addGestureRecognizer(tapGesture)

        fromTextField.inputView = datePickerFrom
        toTextField.inputView = datePickerTo

        hideKeyboardWhenTappedAround()
        configureRx()
    }

    // MARK: - Observers
    @objc func dateChangeFrom(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        fromTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func dateChangeTo(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        toTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func viewTapped(gestureRecognized: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func searchHistoryByDate(_ sender: Any) {
        if let from = fromTextField.text,
           let to = toTextField.text {
            if from.isEmpty && to.isEmpty {
                showAlert(alertText: "GolloPromos", alertMessage: "Fechas incompletas")
            } else {
                fetchHistory(from: from, to: to)
            }
        } else {
            showAlert(alertText: "GolloPromos", alertMessage: "Fechas incompletas")
        }
    }

    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloPromos", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchHistory(from: String, to: String) {
        view.activityStarAnimating()
        viewModel.fetchHistoryTransactions(with: from, endDate: to)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                self.viewModel.status = data
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
}
