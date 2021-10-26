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

    var paymentAmmount: Double = 0.0

    var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        subtotalLabel.text = "₡" + String(paymentAmmount)
        totalLabel.text = "₡" + String(paymentAmmount)
    }

    fileprivate func configureRx() {
        continuePaymentButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//                let vc = CreditCardViewController.instantiate(fromAppStoryboard: .Payments)
//                vc.modalPresentationStyle = .fullScreen
//                vc.paymentAmmount = self.paymentAmmount!
//                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
    }

}
