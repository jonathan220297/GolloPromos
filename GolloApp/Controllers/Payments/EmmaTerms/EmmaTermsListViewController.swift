//
//  EmmaTermsListViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 6/3/23.
//

import UIKit
import RxSwift

class EmmaTermsListViewController: UIViewController {

    @IBOutlet weak var paymentMethodsTableView: UITableView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var shippingStackView: UIStackView!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var bonoStackView: UIStackView!
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var continuePaymentButton: UIButton!
    
    // MARK: - Constants
    let viewModel: EmmaTermsListViewModel
    let bag = DisposeBag()
    
    // MARK: - Lifecycle
    init(viewModel: EmmaTermsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "EmmaTermsListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Seleccione el plazo"
        configureRx()
        configureTableView()
        configureProductPayment()
        fetchEmmaTermsList()
    }

    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self,
                      let error = error else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept(nil)
                }
            })
            .disposed(by: bag)
        
        continuePaymentButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let _ = self.viewModel.termSelected, let _ = self.viewModel.validationPin {
                    
                } else {
                    self.showAlert(alertText: "Gollo App", alertMessage: "Seleccione un plazo a pagar")
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureTableView() {
        paymentMethodsTableView.register(
            UINib(
                nibName: "EmmaTermsTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "EmmaTermsTableViewCell"
        )
    }
    
    fileprivate func fetchEmmaTermsList() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchEmmaTerms()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                print(data)
                self.view.activityStopAnimatingFull()
                self.viewModel.validationPin = Int(data.pinValidacionEmma ?? "0")
                self.viewModel.terms = data.plazos
                self.paymentMethodsTableView.reloadData()
                print("Tamaño de lista: \(self.viewModel.terms.count)")
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureProductPayment() {
        if let subtotal = numberFormatter.string(from: NSNumber(value: round(viewModel.subTotal))),
           let shipping = numberFormatter.string(from: NSNumber(value: round(viewModel.shipping))),
           let bono = numberFormatter.string(from: NSNumber(value: round(viewModel.bonus))) {
            var subtotalAmount = subtotal
            if let formattedString = numberFormatter.string(from: NSNumber(value: round(self.viewModel.getSubtotalAmount()))) {
                subtotalAmount = formattedString
            }
            subtotalLabel.text = "₡" + String(subtotalAmount)
            shippingStackView.isHidden = false
            shippingLabel.text = "₡" + String(shipping)
            bonoStackView.isHidden = true
            bonoLabel.text = "₡" + String(bono)

            var total = round(viewModel.subTotal) + round(viewModel.shipping) - round(viewModel.bonus)
            if let totalAmount = numberFormatter.string(from: NSNumber(value: round(total))), total > 0.0 {
                totalLabel.text = "₡" + String(totalAmount)
            } else {
                totalLabel.text = "₡" + String(subtotal)
            }
        }
    }
    
    fileprivate func sendOrder() {
        viewModel
            .sendOrder()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let paymentMethodSelected = self.viewModel.carManager.paymentMethodSelected else { return }
                self.viewModel.addPurchaseEvent(orderNumber: response.orderId ?? "")
                let _ = self.viewModel.carManager.emptyCar()
                let paymentSuccessViewController = PaymentSuccessViewController(
                    viewModel: PaymentSuccessViewModel(
                        paymentMethodSelected: paymentMethodSelected,
                        productPaymentResponse: response
                    ), cartPayment: false
                )
                paymentSuccessViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(paymentSuccessViewController, animated: true)
            })
            .disposed(by: bag)
    }
    
}

extension EmmaTermsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getEmmaTermsCell(tableView, cellForRowAt: indexPath)
    }
    
    func getEmmaTermsCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmmaTermsTableViewCell", for: indexPath) as? EmmaTermsTableViewCell else {
            return UITableViewCell()
        }
        cell.setMethodData(with: viewModel.terms[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}

extension EmmaTermsListViewController: EmmaTermsCellDelegate {
    func didSelectEmmaOption(at indexPath: IndexPath) {
        for i in 0..<viewModel.terms.count {
            viewModel.terms[i].selected = false
        }
        viewModel.terms[indexPath.row].selected = true
        viewModel.termSelected = viewModel.terms[indexPath.row]
        paymentMethodsTableView.reloadData()
    }
}
