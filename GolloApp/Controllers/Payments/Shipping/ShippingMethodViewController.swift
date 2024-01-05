//
//  ShippingMethodViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import DropDown
import RxSwift
import UIKit

class ShippingMethodViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var shippingMethodsTableView: UITableView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var datePickCollectionView: UICollectionView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var hourPickCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var shoppingMethodsTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Constants
    var viewModel: ShippingMethodViewModel
    var state: String?
    var county: String?
    var district: String?
    let bag = DisposeBag()
    let dateFormatter = DateFormatter()
    
    // MARK: - Lifecycle
    init(viewModel: ShippingMethodViewModel, state: String?, county: String?, district: String?) {
        self.viewModel = viewModel
        self.state = state
        self.county = county
        self.district = district
        super.init(nibName: "ShippingMethodViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Método de envío"
        configureViews()
        configureTableView()
        configureRx()
        fetchShops()
        fetchDeliveryMethods()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Functions
    fileprivate func configureViews() {
        continueButton.layer.cornerRadius = 10.0
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
    }
    
    fileprivate func configureTableView() {
        shippingMethodsTableView.register(
            UINib(
                nibName: "ShippingMethodTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ShippingMethodTableViewCell"
        )
        shippingMethodsTableView.reloadData()
        shoppingMethodsTableViewHeightConstraint.constant = shippingMethodsTableView.contentSize.height + CGFloat(((self.viewModel.methods.count - 1) * 125))
        shippingMethodsTableView.layoutIfNeeded()
        datePickCollectionView.register(UINib(nibName: "DatePickingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DatePickingCollectionViewCell")
        hourPickCollectionView.register(UINib(nibName: "HourPickingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HourPickingCollectionViewCell")
    }
    
    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self,
                let error = error, !error.isEmpty else { return }
                self.view.activityStopAnimatingFull()
                self.view.activityStopAnimating()
                self.viewModel.methods.removeAll()
                self.viewModel.setShippingMethods(true)
                self.viewModel.methodSelected = self.viewModel.methods.first
                self.shippingMethodsTableView.reloadData()
                self.shoppingMethodsTableViewHeightConstraint.constant = self.shippingMethodsTableView.contentSize.height + 50
                self.shippingMethodsTableView.layoutIfNeeded()
                self.stateView.isHidden = false
                self.shopView.isHidden = false
                self.continueButton.isHidden = false
            })
            .disposed(by: bag)
        
        viewModel
            .errorSlotsMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self,
                let error = error, !error.isEmpty else { return }
                self.view.activityStopAnimatingFull()
                self.view.activityStopAnimating()
                self.viewModel.carManager.hasIntaleap = false
                self.scheduleView.isHidden = true
            })
            .disposed(by: bag)
        
        stateButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayStatesList()
            })
            .disposed(by: bag)
        
        shopButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayShopsList()
            })
            .disposed(by: bag)
        
        continueButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if self.viewModel.methods.count == 1 {
                    if self.viewModel.shopSelected != nil {
                        if self.viewModel.carManager.hasIntaleap {
                            if self.viewModel.dateSelected != nil && self.viewModel.hourSelected != nil {
                                self.moveToPaymentMethod()
                            } else {
                                self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar fecha y hora")
                            }
                        } else {
                            self.moveToPaymentMethod()
                        }
                    } else {
                        self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar una tienda")
                    }
                } else if self.viewModel.methods.count > 1 {
                    if self.viewModel.methodSelected != nil {
                        if self.viewModel.methodSelected?.shippingType == "Recoger en tienda" {
                            if self.viewModel.shopSelected != nil {
                                if self.viewModel.carManager.hasIntaleap {
                                    if self.viewModel.dateSelected != nil && self.viewModel.hourSelected != nil {
                                        self.moveToPaymentMethod()
                                    } else {
                                        self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar fecha y hora")
                                    }
                                } else {
                                    self.moveToPaymentMethod()
                                }
                            } else {
                                self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar una tienda")
                            }
                        } else {
                            self.moveToPaymentMethod()
                        }
                    } else {
                        self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar un método de envío")
                    }
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func moveToPaymentMethod() {
        self.viewModel.processShippingMethod()
        let vc = PaymentConfirmViewController.instantiate(fromAppStoryboard: .Payments)
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel.isAccountPayment = false
        vc.viewModel.subTotal = self.viewModel.carManager.total
        vc.viewModel.shipping = self.viewModel.methodSelected?.cost ?? 0.0
        vc.viewModel.bonus = self.viewModel.carManager.bonus
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func fetchShops() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchShops()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.view.activityStopAnimatingFull()
                let responseData = response.sorted { $0.nombre < $1.nombre }
                self.viewModel.data = responseData
                self.viewModel.processStates(with: responseData)
                self.viewModel.processShops(with: self.viewModel.states.first ?? "")
                self.stateLabel.text = self.viewModel.states.first ?? ""
                if let nearStore = viewModel.findUserNearStore() {
                    self.stateLabel.text = nearStore.provincia ?? ""
                    self.viewModel.stateSelected = nearStore.provincia ?? ""
                    self.viewModel.processShops(with: nearStore.provincia ?? "")
                    self.shopLabel.text = ""
                    self.viewModel.shopSelected = nil
                    self.scheduleView.isHidden = true
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchDeliveryMethods() {
        view.activityStartAnimatingFull()
        if let state = state, let county = county, let district = district {
            viewModel
                .fetchDeliveryMethods(
                    idState: state,
                    idCounty: county,
                    idDistrict: district
                )
                .asObservable()
                .subscribe(onNext: {[weak self] response in
                    guard let self = self,
                          let response = response else { return }
                    if let fletes = response.fletes, !fletes.isEmpty {
                        if let _ = fletes.first {
                            for f in fletes {
                                self.viewModel.methods.append(
                                    ShippingMethodData(
                                        cargoCode: f.codigoFlete ?? "",
                                        shippingType: f.nombre ?? "",
                                        shippingDescription: f.descripcion ?? "",
                                        cost: f.monto ?? 0.0,
                                        selected: false
                                    )
                                )
                            }
                            self.viewModel.setShippingMethods(false)
                            self.shippingMethodsTableView.reloadData()
                            self.shoppingMethodsTableViewHeightConstraint.constant = self.shippingMethodsTableView.contentSize.height + CGFloat(((self.viewModel.methods.count - 1) * 125))
                            self.shippingMethodsTableView.layoutIfNeeded()
                            self.stateView.isHidden = true
                            self.shopView.isHidden = true
                            self.continueButton.isHidden = false
                        } else {
                            self.viewModel.setShippingMethods(true)
                            self.stateView.isHidden = false
                            self.shopView.isHidden = false
                            self.continueButton.isHidden = false
                        }
                    } else {
                        self.viewModel.setShippingMethods(true)
                        self.stateView.isHidden = false
                        self.shopView.isHidden = false
                        self.continueButton.isHidden = false
                    }
                    self.view.activityStopAnimatingFull()
                })
                .disposed(by: bag)
        }
    }
    
    fileprivate func fetchAvailableSlots() {
        view.activityStarAnimating()
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
                    self.scheduleView.isHidden = false
                    self.viewModel.responseDate = dates.unique { $0.day ?? "" }
                    self.viewModel.hasInstaleap = true
                    self.datePickCollectionView.reloadData()
                } else {
                    self.viewModel.hasInstaleap = false
                }
                
                self.view.activityStopAnimating()
            })
            .disposed(by: bag)
    }
    
    fileprivate func displayStatesList() {
        let dropDown = DropDown()
        dropDown.anchorView = stateButton
        dropDown.dataSource = viewModel.states
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.stateLabel.text = item
            self.viewModel.stateSelected = item
            self.viewModel.processShops(with: item)
            self.shopLabel.text = ""
            self.viewModel.shopSelected = nil
            self.scheduleView.isHidden = true
        }
        dropDown.show()
    }
    
    fileprivate func displayShopsList() {
        let dropDown = DropDown()
        dropDown.anchorView = shopButton
        dropDown.dataSource = viewModel.shops.map { $0.nombre }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.shopLabel.text = item
            self.viewModel.shopSelected = self.viewModel.shops[index]
            self.scheduleView.isHidden = true
            self.viewModel.carManager.hasIntaleap = (self.viewModel.shopSelected?.aplicaInstaleap == 1)
            validateInstaleap()
        }
        dropDown.show()
    }
    
    fileprivate func validateInstaleap() {
        if self.viewModel.carManager.hasIntaleap && (self.viewModel.carManager.carHasVMI() == 0) && !self.viewModel.carManager.payWithPreApproved {
            self.fetchAvailableSlots()
        } else {
            self.viewModel.carManager.hasIntaleap = false
        }
    }
    
    func getUnique(data: [ResponseDate]) -> [ResponseDate] {
        var set = Set<ResponseDate>()
        var res = [ResponseDate]()

        for d in data {
            if !set.contains(d) {
                res.append(d)
                set.insert(d)
            }
        }
        return res.unique { $0.day ?? "" }
    }
    
    
}

extension ShippingMethodViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.methods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getShippingMethodCell(tableView, cellForRowAt: indexPath)
    }
    
    func getShippingMethodCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingMethodTableViewCell", for: indexPath) as? ShippingMethodTableViewCell else {
            return UITableViewCell()
        }
        cell.setMethodData(with: viewModel.methods[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        return cell
    }
}

extension ShippingMethodViewController: UITableViewDelegate { }

extension ShippingMethodViewController: UICollectionViewDelegate,
                                      UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.datePickCollectionView {
            return viewModel.responseDate.count
        } else {
            return viewModel.hoursAvailabilities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.datePickCollectionView {
            return CGSize(width: 80, height: 90)
        } else {
            return CGSize(width: 140, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.datePickCollectionView {
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

extension ShippingMethodViewController: DatePickingCellDelegate {
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
        datePickCollectionView.reloadData()
        
        if viewModel.responseDate.filter({ $0.selected == true }).isEmpty {
            viewModel.dateSelected = nil
            self.hourLabel.isHidden = true
            self.hourPickCollectionView.isHidden = true
        } else {
            if !hoursAvailabilities.isEmpty {
                self.hourLabel.isHidden = false
                self.hourPickCollectionView.isHidden = false
                self.hourPickCollectionView.reloadData()
            } else {
                self.hourLabel.isHidden = true
                self.hourPickCollectionView.isHidden = true
            }
        }
    }
}

extension ShippingMethodViewController: HourPickingCellDelegate {
    func hourCell(_ productCollectionViewCell: HourPickingCollectionViewCell, willSelectHourWith data: ResponseHours?) {
        for i in 0..<viewModel.hoursAvailabilities.count {
            if viewModel.hoursAvailabilities[i] == data {
                viewModel.hoursAvailabilities[i].selected = !(data?.selected ?? false)
            } else {
                viewModel.hoursAvailabilities[i].selected = false
            }
        }
        
        viewModel.hourSelected = data
        self.hourPickCollectionView.reloadData()
        
        if self.viewModel.hoursAvailabilities.filter({ $0.selected == true }).isEmpty {
            viewModel.hourSelected = nil
        }
    }
}

extension ShippingMethodViewController: ShippingMethodCellDelegate {
    func didSelectMethod(at indexPath: IndexPath) {
        for i in 0..<viewModel.methods.count {
            viewModel.methods[i].selected = false
        }

        viewModel.methods[indexPath.row].selected = true
        shippingMethodsTableView.reloadData()
        viewModel.methodSelected = viewModel.methods[indexPath.row]
        if let method = viewModel.methodSelected, method.selected, method.cargoCode != "-1" {
            self.stateView.isHidden = true
            self.shopView.isHidden = true
            self.continueButton.isHidden = false
        } else {
            self.stateView.isHidden = false
            self.shopView.isHidden = false
            self.continueButton.isHidden = false
            
            if let carManagerType = self.viewModel.verifyCarManagerTypeState(), carManagerType == CarManagerType.SCAN_AND_GO.rawValue, let store = viewModel.findSelectedStore() {
                stateLabel.text = store.provincia ?? ""
                viewModel.stateSelected = store.provincia ?? ""
                shopLabel.text = store.nombre
                viewModel.shopSelected = store
                stateButton.isEnabled = false
                shopButton.isEnabled = false
            } else {
                if let nearStore = viewModel.findUserNearStore() {
                    self.stateLabel.text = nearStore.provincia ?? ""
                    self.viewModel.stateSelected = nearStore.provincia ?? ""
                    self.viewModel.processShops(with: nearStore.provincia ?? "")
                    self.shopLabel.text = ""
                    self.viewModel.shopSelected = nil
                    self.scheduleView.isHidden = true
                }
                
                stateButton.isEnabled = true
                shopButton.isEnabled = true
            }
        }
    }
}
