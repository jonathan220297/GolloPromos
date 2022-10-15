//
//  PaymentConfirmViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import UIKit
import RxSwift

class PaymentConfirmViewController: UIViewController {

    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var shippingStackView: UIStackView!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var bonoStackView: UIStackView!
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var continuePaymentButton: UIButton!

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
        fetchPaymentMehtods()
    }

    fileprivate func configureRx() {
        continuePaymentButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let vc = PaymentDataViewController.instantiate(fromAppStoryboard: .Payments)
                vc.modalPresentationStyle = .fullScreen
                vc.viewModel.paymentData = self.paymentData
                vc.viewModel.paymentAmount = self.paymentAmmount
                vc.viewModel.isAccountPayment = self.viewModel.isAccountPayment
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
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
