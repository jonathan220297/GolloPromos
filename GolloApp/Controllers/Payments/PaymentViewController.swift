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
    @IBOutlet weak var otherAmountView: UIView!
    @IBOutlet weak var otherAmountTextField: UITextField!
    @IBOutlet weak var otherAmountButton: UIButton!
    @IBOutlet weak var otherAmountErrorLabel: UILabel!
    
    let dateFormatter = DateFormatter()

    var paymentData: PaymentData? = nil
    var isThirdPayAccount: Bool = false
    var antiLaunderingAmount: Double = 0.0
    var cardTypePayment: Bool = false
    var currentAmount: Double? = 0.0
    var selectedPaymentAmount = -1
    var errorAmount: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Opciones de pago"
        configureViews()
        dateFormatter.dateStyle = .long
        otherAmountTextField.isEnabled = false
        showData()
        navigationController?.navigationBar.isHidden = false
        hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

    // MARK: - Observers
    @objc func otherAmountTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
        if let otherAmountString = textField.text {
            let doubleAmount = Double(otherAmountString.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "₡", with: "")) ?? 0.0
            let sugestedAmount = round(paymentData?.totalAmount ?? 0.0)

            if doubleAmount > sugestedAmount {
                otherAmountErrorLabel.text = "Monto ingresado es mayor al total a cancelar."
                otherAmountErrorLabel.isHidden = false
                errorAmount = true
            } else {
                otherAmountErrorLabel.isHidden = true
                errorAmount = false
            }
        } else {
            otherAmountErrorLabel.isHidden = true
            errorAmount = false
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonAmountPaymentTapped(_ sender: UIButton) {
        [suggestedAmountButton, installmentButton, totalPendingButton, otherAmountButton].forEach { (button) in
            button?.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
            otherAmountView.isHidden = true
        }
        if sender == suggestedAmountButton {
            selectedPaymentAmount = Payment.PAYMENT_SUGGESTED.rawValue
            currentAmount = paymentData?.suggestedAmount
            otherAmountTextField.isEnabled = false
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
            otherAmountView.isHidden = true
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
            otherAmountView.isHidden = true
        }
        if sender == totalPendingButton {
            selectedPaymentAmount = Payment.PAYMENT_TOTAL_PENDING.rawValue
            currentAmount = paymentData?.totalAmount
            otherAmountTextField.isEnabled = false
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
            otherAmountView.isHidden = true
        }
        if sender == otherAmountButton {
            otherAmountTextField.isEnabled = true
            sender.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
            otherAmountView.isHidden = false
        }
    }

    @IBAction func payment(_ sender: Any) {
        if otherAmountView.isHidden && validateAmountData() {
            if self.isThirdPayAccount && self.currentAmount! > self.antiLaunderingAmount {
                self.showProvenanceViewController()
            } else {
                self.showPaymentConfirmViewController()
            }
        } else if !otherAmountView.isHidden {
            if !errorAmount {
                guard let amount = otherAmountTextField.text else { return }
                let amountDouble = Double(amount.replacingOccurrences(of: "₡", with: "").replacingOccurrences(of: ",", with: "")) ?? 0.0
                if amountDouble > 0.0 {
                    self.currentAmount = amountDouble
                    if self.isThirdPayAccount && self.currentAmount! > self.antiLaunderingAmount {
                        self.showProvenanceViewController()
                    } else {
                        self.showPaymentConfirmViewController()
                    }
                } else if amount.isEmpty {
                    self.setErrorLabel(with: "Monto es requerido")
                }
            }
        } else {
            self.showAlert(alertText: "GolloApp", alertMessage: "Seleccione monto de pago")
        }
    }

    // MARK: - Functions
    private func configureViews() {
        otherAmountTextField.addTarget(self, action: #selector(otherAmountTextFieldDidChange), for: .editingChanged)
    }
    
    private func showPaymentConfirmViewController() {
        DispatchQueue.main.async {
            let vc = PaymentConfirmViewController.instantiate(fromAppStoryboard: .Payments)
            vc.modalPresentationStyle = .fullScreen
            vc.paymentAmmount = self.currentAmount!
            vc.paymentData = self.paymentData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func showProvenanceViewController() {
        DispatchQueue.main.async {
            let provenanceViewController = ProvenanceViewController(
                viewModel: ProvenanceViewModel(),
                paymentData: self.paymentData,
                currentAmount: self.currentAmount
            )
            provenanceViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(provenanceViewController, animated: true)
        }
    }

    private func setErrorLabel(with text: String) {
        otherAmountErrorLabel.isHidden = false
        otherAmountErrorLabel.text = text
    }
    
    fileprivate func showData() {
        if let model = paymentData {
            if let suggested = numberFormatter.string(from: NSNumber(value: round(model.suggestedAmount ?? 0.0))) {
                suggestedAmountLabel.text = "₡" + String(suggested)
            }
            if let pending = numberFormatter.string(from: NSNumber(value: round(model.totalAmount ?? 0.0))) {
                totalPendingLabel.text = "₡" + String(pending)
            }
            if let installment = numberFormatter.string(from: NSNumber(value: round(model.installmentAmount ?? 0.0))) {
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

extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {
    
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "₡"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    
        var amountWithPrefix = self
    
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
    
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
    
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
    
        return formatter.string(from: number)!
    }
}
