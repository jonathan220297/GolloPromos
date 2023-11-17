//
//  PresaleViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 15/11/23.
//

import UIKit
import RxSwift

protocol PresaleDelegate: AnyObject {
    func sendCrediGolloOrder(with plazo: Int, prima: Double)
}

class PresaleViewController: UIViewController {
    
    @IBOutlet weak var initialAmountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var otherAmountErrorLabel: UILabel!
    @IBOutlet weak var currentPlazoLabel: UILabel!
    @IBOutlet weak var plazoSlider: UISlider!
    @IBOutlet weak var minPeriodLabel: UILabel!
    @IBOutlet weak var maxPeriodLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var monthlyAmountLabel: UILabel!
    @IBOutlet weak var interestRateAmountLabel: UILabel!
    @IBOutlet weak var financeAmountLabel: UILabel!
    @IBOutlet weak var financingInterestLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var plazoView: UIView!
    @IBOutlet weak var detailView: UIView!
    
    // MARK: - Constants
    let viewModel: PresaleViewModel
    let bag = DisposeBag()
    weak var delegate: PresaleDelegate?
    var keyboardShowing: Bool = false
    var errorAmount: Bool = false
    
    init(viewModel: PresaleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PresaleViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detalle del CrediGollo"
        configureViews()
        configureRx()
        fetchCrediGolloTerms()
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
    @objc func closePopUp() {
        hideKeyboardWhenTappedAround()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardShowing = true
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardShowing = false
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.digitsOnly(), let amountDouble = Double(amountString), let formmatedAmount = numberFormatter.string(from: NSNumber(value: amountDouble)) {
            textField.text = "₡" + formmatedAmount
        }
        if let otherAmountString = textField.text {
            let doubleAmount = Double(otherAmountString.digitsOnly()) ?? 0.0
            let sugestedAmount = round(viewModel.subTotal)
            viewModel.currentPrima = doubleAmount

            if doubleAmount >= sugestedAmount {
                otherAmountErrorLabel.text = "La prima no puede ser igual o mayor al monto del crédito"
                otherAmountErrorLabel.isHidden = false
                errorAmount = true
            } else if doubleAmount < (viewModel.presaleDetail?.montoPrimaMinimo ?? 0.0) {
                otherAmountErrorLabel.text = "El monto de la prima es menor al requerido, monto minimo requerido de prima: ₡\(viewModel.presaleDetail?.montoPrimaMinimo ?? 0.0)"
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
        showControls(with: true)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        currentPlazoLabel.text = String(Int(plazoSlider.value))
        viewModel.selectedTerm = Int(plazoSlider.value)
        viewModel.currentTerm = viewModel.presaleDetail?.plazos?.first { $0.cantidadMeses == viewModel.selectedTerm }
        showDetails()
    }
    
    fileprivate func configureViews() {
        if let initial = numberFormatter.string(from: NSNumber(value: round(viewModel.subTotal))) {
            initialAmountLabel.text = "₡" + String(initial)
        } else {
            initialAmountLabel.text = "₡0.00"
        }
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
                    showControls(with: true)
                    self.view.activityStopAnimatingFull()
                }
            })
            .disposed(by: bag)
        
        updateButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if !self.errorAmount {
                    self.fetchCrediGolloTerms()
                }
            })
            .disposed(by: bag)
        
        confirmButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true, completion: {
                    self.delegate?.sendCrediGolloOrder(with: self.viewModel.selectedTerm, prima: self.viewModel.currentPrima)
                })
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchCrediGolloTerms() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchCrediGolloTerms()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimatingFull()
                viewModel.presaleDetail = data
                showTerms(with: data.plazos ?? [])
                showDetails()
                showControls(with: false)
                if let minPrima = data.montoPrimaMinimo, minPrima > 0, let formmatedAmount = numberFormatter.string(from: NSNumber(value: minPrima)) {
                    self.amountTextField.text = "₡" + formmatedAmount
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func showTerms(with terms: [CrediGolloTerm]) {
        if !terms.isEmpty {
            let minValue = terms.map { $0.cantidadMeses }.min()
            let maxValue = terms.map { $0.cantidadMeses }.max()
            plazoSlider.minimumValue = Float(minValue ?? 0)
            plazoSlider.maximumValue = Float(maxValue ?? 0)
            minPeriodLabel.text = String(minValue ?? 0)
            maxPeriodLabel.text = String(maxValue ?? 0)
            currentPlazoLabel.text  = String(maxValue ?? 0)
            if viewModel.selectedTerm > 0 && isValidTerm(with: viewModel.selectedTerm, terms: terms) {
                plazoSlider.value = Float(viewModel.selectedTerm)
            } else {
                plazoSlider.value = Float(maxValue ?? 0)
            }
            viewModel.selectedTerm = maxValue ?? 0
            viewModel.currentTerm = viewModel.presaleDetail?.plazos?.first { $0.cantidadMeses == viewModel.selectedTerm }
        }
    }
    
    fileprivate func showDetails() {
        if let currentTerm = viewModel.currentTerm {
            if let monthly = numberFormatter.string(from: NSNumber(value: round(currentTerm.montoMensual))) {
                monthlyAmountLabel.text = "₡" + String(monthly)
            }
            let interestAmount = (currentTerm.tasaEfectiva / 12)
                interestRateAmountLabel.text = String(interestAmount) + "%" 
            if let finance = numberFormatter.string(from: NSNumber(value: round(viewModel.subTotal - viewModel.currentPrima))) {
                financeAmountLabel.text = "₡" + String(finance)
            }
            if let totalInteres = numberFormatter.string(from: NSNumber(value: round(currentTerm.montoIntereses))) {
                financingInterestLabel.text = "₡" + String(totalInteres)
            }
            if let total = numberFormatter.string(from: NSNumber(value: round(currentTerm.montoTotal))) {
                totalAmountLabel.text = "₡" + String(total)
            }
        }
    }
    
    fileprivate func showControls(with hiden: Bool) {
        updateButton.isHidden = !hiden
        plazoView.isHidden = hiden
        detailView.isHidden = hiden
        confirmButton.isHidden = hiden
    }
    
    fileprivate func isValidTerm(with term: Int, terms: [CrediGolloTerm]) -> Bool {
        return terms.filter { $0.cantidadMeses == term }.count > 0
    }

}
