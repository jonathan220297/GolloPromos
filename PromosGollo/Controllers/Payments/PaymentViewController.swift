//
//  PaymentViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var suggestedAmountTitleLabel: UILabel!
    @IBOutlet weak var suggestedAmountView: UIView!
    @IBOutlet weak var suggestedAmountHeight: NSLayoutConstraint!
    @IBOutlet weak var suggestedAmountLabel: UILabel!
    @IBOutlet weak var suggestedAmountButton: UIButton!
    @IBOutlet weak var installmentTitleLabel: UILabel!
    @IBOutlet weak var installmentLabel: UILabel!
    @IBOutlet weak var installmentButton: UIButton!
    @IBOutlet weak var totalPendingTitleLabel: UILabel!
    @IBOutlet weak var totalPendingView: UIView!
    @IBOutlet weak var totalPendingHeigth: NSLayoutConstraint!
    @IBOutlet weak var totalPendingLabel: UILabel!
    @IBOutlet weak var totalPendingButton: UIButton!
    @IBOutlet weak var otherAmountTextField: UITextField!
    @IBOutlet weak var otherAmountButton: UIButton!

    let dateFormatter = DateFormatter()

    var paymentData: PaymentData? = nil
    var isThirdPayAccount: Bool = false
    var cardTypePayment: Bool = false
    var currentAmount: Double? = 0.0
    var selectedPaymentAmount = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .long
        otherAmountTextField.isEnabled = false
        showData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func buttonAmountPaymentTapped(_ sender: UIButton) {
        [suggestedAmountButton, installmentButton, totalPendingButton, otherAmountButton].forEach { (button) in
            button?.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
        }
        if sender == suggestedAmountButton {
            selectedPaymentAmount = Payment.PAYMENT_SUGGESTED.rawValue
            currentAmount = paymentData?.suggestedAmount
            otherAmountTextField.isEnabled = false
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
        }
        if sender == installmentButton {
            selectedPaymentAmount = Payment.PAYMENT_INSTALLMENT.rawValue
            var amountSelected: Double? = 0.0
            if isThirdPayAccount {
                amountSelected = paymentData?.totalAmount
            } else {
                amountSelected = paymentData?.installmentAmount
            }
            currentAmount = amountSelected
            otherAmountTextField.isEnabled = false
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
        }
        if sender == totalPendingButton {
            selectedPaymentAmount = Payment.PAYMENT_TOTAL_PENDING.rawValue
            currentAmount = paymentData?.totalAmount
            otherAmountTextField.isEnabled = false
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
        }
        if sender == otherAmountButton {
            otherAmountTextField.isEnabled = true
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
            self.showAlert(alertText: "GolloApp", alertMessage: "Seleccione monto de pago")
        }
    }

    // MARK: - Functions
    fileprivate func showData() {
        if let model = paymentData {
            if let suggested = numberFormatter.string(from: NSNumber(value: model.suggestedAmount ?? 0.0)) {
                suggestedAmountLabel.text = "₡" + String(suggested)
            }
            if let pending = numberFormatter.string(from: NSNumber(value: model.totalAmount ?? 0.0)) {
                totalPendingLabel.text = "₡" + String(pending)
            }
            if let installment = numberFormatter.string(from: NSNumber(value: model.installmentAmount ?? 0.0)) {
                installmentLabel.text = "₡" + String(installment)
            }
        }
        if isThirdPayAccount {
            DispatchQueue.main.async {
                self.suggestedAmountView.visibility = .gone
                self.suggestedAmountHeight.constant = 0
                self.suggestedAmountView.layoutIfNeeded()
                self.totalPendingView.visibility = .gone
                self.totalPendingHeigth.constant = 0
                self.totalPendingView.layoutIfNeeded()
            }
            self.installmentLabel.text = "Monto a pagar"
            if let pending = numberFormatter.string(from: NSNumber(value: self.paymentData?.totalAmount ?? 0.0)) {
                self.installmentLabel.text = "₡" + String(pending)
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
