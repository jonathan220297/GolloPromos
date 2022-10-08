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
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var shoppingMethodsTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Constants
    var viewModel: ShippingMethodViewModel
    let bag = DisposeBag()
    
    // MARK: - Lifecycle
    init(viewModel: ShippingMethodViewModel) {
        self.viewModel = viewModel
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
                if self.viewModel.shopSelected != nil {
                    self.viewModel.processShippingMethod()
                    let vc = PaymentConfirmViewController.instantiate(fromAppStoryboard: .Payments)
                    vc.modalPresentationStyle = .fullScreen
                    vc.viewModel.isAccountPayment = false
                    vc.viewModel.subTotal = self.viewModel.carManager.total
                    vc.viewModel.shipping = 0.0
                    vc.viewModel.bonus = 0.0
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Debes seleccionar una tienda")
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchShops() {
        view.activityStarAnimating()
        viewModel
            .fetchShops()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.view.activityStopAnimating()
                self.viewModel.data = response
                self.viewModel.processStates(with: response)
                self.viewModel.processShops(with: self.viewModel.states.first ?? "")
                self.stateLabel.text = self.viewModel.states.first ?? ""
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
        cell.selectionStyle = .none
        return cell
    }
}

extension ShippingMethodViewController: UITableViewDelegate { }