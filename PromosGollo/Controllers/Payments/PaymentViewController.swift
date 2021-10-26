//
//  PaymentViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var suggestedAmountLabel: UILabel!
    @IBOutlet weak var suggestedAmountButton: UIButton!
    @IBOutlet weak var installmentLabel: UILabel!
    @IBOutlet weak var installmentButton: UIButton!
    @IBOutlet weak var totalPendingLabel: UILabel!
    @IBOutlet weak var totalPendingButton: UIButton!
    @IBOutlet weak var otherAmountTextField: UITextField!

    let dateFormatter = DateFormatter()

    var paymentData: PaymentData? = nil
    var cardTypePayment: Bool = false
    var currentAmount: Double? = 0.0
    var selectedPaymentAmount = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()

        self.viewPopup.clipsToBounds = true

        dateFormatter.dateStyle = .long

        showData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func buttonAmountPaymentTapped(_ sender: UIButton) {
        [suggestedAmountButton, installmentButton, totalPendingButton].forEach { (button) in
            button?.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
        }
        if sender == suggestedAmountButton {
            selectedPaymentAmount = Payment.PAYMENT_SUGGESTED.rawValue
            currentAmount = paymentData?.suggestedAmount
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
        }
        if sender == installmentButton {
            selectedPaymentAmount = Payment.PAYMENT_INSTALLMENT.rawValue
            currentAmount = paymentData?.installmentAmount
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
        }
        if sender == totalPendingButton {
            selectedPaymentAmount = Payment.PAYMENT_TOTAL_PENDING.rawValue
            currentAmount = paymentData?.totalAmount
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
        }
    }

    @IBAction func payment(_ sender: Any) {
        if (validateAmountData()) {
            DispatchQueue.main.async {
                let vc = PaymentConfirmViewController.instantiate(fromAppStoryboard: .Payments)
                vc.modalPresentationStyle = .fullScreen
                vc.paymentAmmount = self.currentAmount!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.showAlert(alertText: "GolloPromos", alertMessage: "Seleccione monto de pago")
        }
    }

    // MARK: - Functions
    fileprivate func showData() {
        if let model = paymentData {
            if let suggested = numberFormatter.string(from: NSNumber(value: model.suggestedAmount ?? 0.0)) {
                suggestedAmountLabel.text = "₡" + " " + String(suggested)
            }
            if let pending = numberFormatter.string(from: NSNumber(value: model.totalAmount ?? 0.0)) {
                totalPendingLabel.text = "₡" + " " + String(pending)
            }
            if let installment = numberFormatter.string(from: NSNumber(value: model.installmentAmount ?? 0.0)) {
                installmentLabel.text = "₡" + " " + String(installment)
            }
        }
    }

    fileprivate func validateAmountData() -> Bool {
        if selectedPaymentAmount == -1  {
            if let specifiedAmount = otherAmountTextField.text {
                currentAmount = Double(specifiedAmount)
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

}
