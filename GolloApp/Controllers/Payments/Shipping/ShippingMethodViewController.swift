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
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var shoppingMethodsTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Constants
    var viewModel: ShippingMethodViewModel
    var state: String?
    var county: String?
    var district: String?
    let bag = DisposeBag()
    
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
        shoppingMethodsTableViewHeightConstraint.constant = shippingMethodsTableView.contentSize.height + 35
    }
    
    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self,
                let error = error, !error.isEmpty else { return }
                self.view.activityStopAnimatingFull()
                self.viewModel.methods.removeAll()
                self.viewModel.setShippingMethods(true)
                self.viewModel.methodSelected = self.viewModel.methods.first
                self.shippingMethodsTableView.reloadData()
                self.shoppingMethodsTableViewHeightConstraint.constant = self.shippingMethodsTableView.contentSize.height + 35
                self.stateView.isHidden = false
                self.shopView.isHidden = false
                self.continueButton.isHidden = false
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
                        self.moveToPaymentMethod()
                    } else {
                        self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar una tienda")
                    }
                } else if self.viewModel.methods.count > 1 {
                    if self.viewModel.methodSelected != nil {
                        if self.viewModel.methodSelected?.shippingType == "Recoger en tienda" {
                            if self.viewModel.shopSelected != nil {
                                self.moveToPaymentMethod()
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
                self.viewModel.data = response
                self.viewModel.processStates(with: response)
                self.viewModel.processShops(with: self.viewModel.states.first ?? "")
                self.stateLabel.text = self.viewModel.states.first ?? ""
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
                        if let store = fletes.first {
                            self.viewModel.setShippingMethods(false)
                            self.viewModel.methods.insert(
                                ShippingMethodData(
                                    cargoCode: store.codigoFlete ?? "",
                                    shippingType: store.nombre ?? "",
                                    shippingDescription: store.descripcion ?? "",
                                    cost: store.monto ?? 0.0,
                                    selected: false
                                ),
                                at: 0
                            )
                            self.shippingMethodsTableView.reloadData()
                            self.shoppingMethodsTableViewHeightConstraint.constant = self.shippingMethodsTableView.contentSize.height + 100
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
    
    fileprivate func displayStatesList() {
        let dropDown = DropDown()
        dropDown.anchorView = stateButton
        dropDown.dataSource = viewModel.states
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.stateLabel.text = item
            self.viewModel.stateSelected = item
            self.viewModel.processShops(with: item)
            self.shopLabel.text = self.viewModel.shops.first?.nombre ?? ""
            self.viewModel.shopSelected = self.viewModel.shops.first
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
        }
        dropDown.show()
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

extension ShippingMethodViewController: ShippingMethodCellDelegate {
    func didSelectMethod(at indexPath: IndexPath) {
        for i in 0..<viewModel.methods.count {
            viewModel.methods[i].selected = false
        }

        viewModel.methods[indexPath.row].selected = true
        shippingMethodsTableView.reloadData()
        viewModel.methodSelected = viewModel.methods[indexPath.row]
        if let method = viewModel.methods.first, method.selected {
            self.stateView.isHidden = true
            self.shopView.isHidden = true
            self.continueButton.isHidden = false
        } else {
            self.stateView.isHidden = false
            self.shopView.isHidden = false
            self.continueButton.isHidden = false
        }
    }
}
