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
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var continuePaymentButton: UIButton!

    var paymentData: PaymentData?
    var paymentAmmount: Double = 0.0

    var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        if let suggested = numberFormatter.string(from: NSNumber(value: round(paymentAmmount))) {
            subtotalLabel.text = "₡" + String(suggested)
            totalLabel.text = "₡" + String(suggested)
        }
        
        configureRx()
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
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
    }
}

extension PaymentConfirmViewController: PaymentDataDelegate {
    func errorWhilePayment(with message: String) {
        showAlert(alertText: "Error", alertMessage: message)
    }
}
