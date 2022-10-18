//
//  PaymentConfirmViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import UIKit
import RxSwift

class PaymentConfirmViewController: UIViewController {

    @IBOutlet weak var paymentMethodsTableView: UITableView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var shippingStackView: UIStackView!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var bonoStackView: UIStackView!
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var continuePaymentButton: UIButton!

    @IBOutlet weak var paymentMethodsTableViewHeightConstaint: NSLayoutConstraint!
    
    var paymentData: PaymentData?
    var paymentAmmount: Double = 0.0

    var bag = DisposeBag()
    
    lazy var viewModel: PaymentConfirmViewModel = {
        let vm = PaymentConfirmViewModel()
        return vm
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Método de pago"
        navigationController?.navigationBar.isHidden = false
        if viewModel.isAccountPayment {
            configureAccountPayment()
        } else {
            configureProductPayment()
        }
        configureRx()
        configureTableView()
        fetchPaymentMehtods()
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
    
    fileprivate func configureTableView() {
        paymentMethodsTableView.register(
            UINib(
                nibName: "PaymentMethodTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "PaymentMethodTableViewCell"
        )
    }

    fileprivate func configureRx() {
        continuePaymentButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let methodSelected = self.viewModel.methodSelected {
                    if methodSelected.indTarjeta == 1 {
                        let vc = PaymentDataViewController.instantiate(fromAppStoryboard: .Payments)
                        vc.modalPresentationStyle = .fullScreen
                        vc.viewModel.paymentData = self.paymentData
                        vc.viewModel.paymentAmount = self.paymentAmmount
                        vc.viewModel.isAccountPayment = self.viewModel.isAccountPayment
                        vc.delegate = self
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        
                    }
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Debes elegir un método de pago para continuar")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchPaymentMehtods() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchPaymentMethods()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                print(data)
                self.view.activityStopAnimatingFull()
                self.viewModel.methods = data
                self.paymentMethodsTableView.reloadData()
                self.paymentMethodsTableViewHeightConstaint.constant = self.paymentMethodsTableView.contentSize.height + 40
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureAccountPayment() {
        if let suggested = numberFormatter.string(from: NSNumber(value: round(paymentAmmount))) {
            subtotalLabel.text = "₡" + String(suggested)
            totalLabel.text = "₡" + String(suggested)
        }
    }
    
    fileprivate func configureProductPayment() {
        if let subtotal = numberFormatter.string(from: NSNumber(value: round(viewModel.subTotal))),
           let shipping = numberFormatter.string(from: NSNumber(value: round(viewModel.shipping))),
           let bono = numberFormatter.string(from: NSNumber(value: round(viewModel.bonus))) {
            subtotalLabel.text = "₡" + String(subtotal)
            shippingStackView.isHidden = false
            shippingLabel.text = "₡" + String(shipping)
            bonoStackView.isHidden = false
            bonoLabel.text = "₡" + String(bono)
            totalLabel.text = "₡" + String(subtotal)
        }
    }
}

extension PaymentConfirmViewController: PaymentDataDelegate {
    func errorWhilePayment(with message: String) {
        showAlert(alertText: "Error", alertMessage: message)
    }
}

extension PaymentConfirmViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.methods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getPaymentMethodsCell(tableView, cellForRowAt: indexPath)
    }
    
    func getPaymentMethodsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath) as? PaymentMethodTableViewCell else {
            return UITableViewCell()
        }
        cell.setMethodData(with: viewModel.methods[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}

extension PaymentConfirmViewController: PaymentMethodCellDelegate {
    func didSelectPaymentMethod(at indexPath: IndexPath) {
        for i in 0..<viewModel.methods.count {
            viewModel.methods[i].selected = false
        }
        viewModel.methods[indexPath.row].selected = true
        viewModel.methodSelected = viewModel.methods[indexPath.row]
        paymentMethodsTableView.reloadData()
    }
}
