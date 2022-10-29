//
//  PaymentDataViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 18/8/22.
//

import UIKit
import RxSwift
import DropDown

protocol PaymentDataDelegate: AnyObject {
    func errorWhilePayment(with message: String)
}

class PaymentDataViewController: UIViewController {
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationMonthLabel: UILabel!
    @IBOutlet weak var expirationMonthButton: UIButton!
    @IBOutlet weak var expirationYearLabel: UILabel!
    @IBOutlet weak var expirationYearButton: UIButton!
    @IBOutlet weak var cardNameTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet weak var zeroRateView: UIView!
    @IBOutlet weak var zeroRateLabel: UILabel!
    @IBOutlet weak var zeroRateButton: UIButton!

    lazy var viewModel: PaymentDataViewModel = {
        return PaymentDataViewModel()
    }()
    let bag = DisposeBag()
    weak var delegate: PaymentDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "PaymentDataViewController_title".localized

        cardNumberTextField.delegate = self
        cvvTextField.delegate = self
        configureRx()
        hideKeyboardWhenTappedAround()

        if self.viewModel.zeroRatePayment {
            zeroRateView.isHidden = false
//            if let first = self.viewModel.zeroRateList.first {
//                self.zeroRateLabel.text = first.descPlazo
//                self.viewModel.zeroRateSubject.accept(first.idPlazo)
//            }
        } else {
            zeroRateView.isHidden = true
        }
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
    
    // MARK: - Functions
    fileprivate func configureRx() {
        cardNumberTextField.rx.text.bind(to: viewModel.cardNumberSubject).disposed(by: bag)
        expirationMonthButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayMonths()
            })
            .disposed(by: bag)
        expirationYearButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayYears()
            })
            .disposed(by: bag)
        zeroRateButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayZeroRate()
            })
            .disposed(by: bag)
        cardNameTextField.rx.text.bind(to: viewModel.cardNameSubject).disposed(by: bag)
        cvvTextField.rx.text.bind(to: viewModel.cardCvvSubject).disposed(by: bag)
        viewModel.isValidForm.bind(to: continueButton.rx.isEnabled).disposed(by: bag)
        viewModel.isValidForm.map { $0 ? 1 : 0.4 }.bind(to: continueButton.rx.alpha).disposed(by: bag)
        
        continueButton.rx
            .tap
            .subscribe(onNext: {
                if self.viewModel.isAccountPayment {
                    self.makeAccountPayment()
                } else {
                    self.makeProductPayment()
                }
            })
            .disposed(by: bag)
        
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.continueButton.hideLoading()
                    self.viewModel.errorMessage.accept("")
                    self.navigationController?.popViewController(animated: true, completion: {
                        self.delegate?.errorWhilePayment(with: error)
                    })
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func displayMonths() {
        let dropDown = DropDown()
        dropDown.anchorView = expirationMonthButton
        dropDown.dataSource = viewModel.months.map{ String($0) }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.expirationMonthLabel.text = item
            self.viewModel.expirationNumberSubject.accept(self.viewModel.months[index])
        }
        dropDown.show()
    }
    
    fileprivate func displayYears() {
        let dropDown = DropDown()
        dropDown.anchorView = expirationYearButton
        viewModel.fillYears()
        dropDown.dataSource = viewModel.years.map{ String($0) }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.expirationYearLabel.text = item
            self.viewModel.expirationYearSubject.accept(self.viewModel.years[index])
        }
        dropDown.show()
    }

    fileprivate func displayZeroRate() {
        let dropDown = DropDown()
        dropDown.anchorView = zeroRateButton
        viewModel.fillYears()
        dropDown.dataSource = viewModel.zeroRateList.map{ $0.descPlazo ?? "" }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.zeroRateLabel.text = item
            self.viewModel.zeroRateSubject.accept(self.viewModel.zeroRateList[index].idPlazo)
        }
        dropDown.show()
    }
    
    private func makeAccountPayment() {
        continueButton.showLoading()
        viewModel
            .makeGolloPayment()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let _ = self.viewModel.carManager.paymentMethodSelected else { return }
                if let url = response.url, !url.isEmpty {
                    let verifyPaymentViewController = VerifyPaymentViewController()
                    verifyPaymentViewController.modalPresentationStyle = .fullScreen
                    verifyPaymentViewController.delegate = self
                    verifyPaymentViewController.redirectURL = url
                    verifyPaymentViewController.processId = response.idProceso ?? ""
                    self.navigationController?.pushViewController(verifyPaymentViewController, animated: true)
                } else {
                    self.continueButton.hideLoading()
                    self.viewModel.errorMessage.accept("")
                    self.navigationController?.popViewController(animated: true, completion: {
                        self.delegate?.errorWhilePayment(with: "No es posible verificar la transacción")
                    })
                }
            })
            .disposed(by: bag)
    }
    
    private func makeProductPayment() {
        viewModel.setCardData()
        continueButton.showLoading()
        viewModel
            .makeProductPayment()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let paymentMethodSelected = self.viewModel.carManager.paymentMethodSelected else { return }
                print(response)
                if let redirect = response.indRedirect, redirect == 0 {
                    let _ = self.viewModel.carManager.emptyCar()
                    self.continueButton.hideLoading()
                    let paymentSuccessViewController = PaymentSuccessViewController(
                        viewModel: PaymentSuccessViewModel(
                            paymentMethodSelected: paymentMethodSelected,
                            productPaymentResponse: response
                        ), cartPayment: true
                    )
                    paymentSuccessViewController.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(paymentSuccessViewController, animated: true)
                } else {
                    if let url = response.url, !url.isEmpty {
                        let verifyPaymentViewController = VerifyPaymentViewController()
                        verifyPaymentViewController.modalPresentationStyle = .fullScreen
                        verifyPaymentViewController.delegate = self
                        verifyPaymentViewController.redirectURL = url
                        verifyPaymentViewController.processId = response.idProceso ?? ""
                        self.navigationController?.pushViewController(verifyPaymentViewController, animated: true)
                    } else {
                        self.continueButton.hideLoading()
                        self.viewModel.errorMessage.accept("")
                        self.navigationController?.popViewController(animated: true, completion: {
                            self.delegate?.errorWhilePayment(with: "No es posible verificar la transacción")
                        })
                    }
                }
            })
            .disposed(by: bag)
    }

    private func getPaymentResult(with id: String) {
        viewModel
            .getPaymentResponseDetail(with: id)
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let paymentMethodSelected = self.viewModel.carManager.paymentMethodSelected else { return }
                print(response)
                self.continueButton.hideLoading()
                let paymentSuccessViewController = PaymentSuccessViewController(
                    viewModel: PaymentSuccessViewModel(
                        paymentMethodSelected: paymentMethodSelected,
                        accountPaymentResponse: response
                    ), cartPayment: true
                )
                paymentSuccessViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(paymentSuccessViewController, animated: true)
            })
            .disposed(by: bag)
    }

    private func getProductPaymentResult(with id: String) {
        viewModel
            .getProductPaymentResponseDetail(with: id)
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let paymentMethodSelected = self.viewModel.carManager.paymentMethodSelected else { return }
                print(response)
                let _ = self.viewModel.carManager.emptyCar()
                self.continueButton.hideLoading()
                let paymentSuccessViewController = PaymentSuccessViewController(
                    viewModel: PaymentSuccessViewModel(
                        paymentMethodSelected: paymentMethodSelected,
                        productPaymentResponse: response
                    ), cartPayment: true
                )
                paymentSuccessViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(paymentSuccessViewController, animated: true)
            })
            .disposed(by: bag)
    }
    
//    fileprivate func setCardData() {
//        if viewModel.setCardData() {
//            viewModel.buildOrderRequest()
//            createOrder()
//        }
//    }
//
//    fileprivate func createOrder() {
//        continueButton.showLoading()
//        viewModel.createOrder()
//            .asObservable()
//            .subscribe(onNext: {[weak self] response in
//                guard let self = self,
//                      let response = response else { return }
//                DispatchQueue.main.async {
//                    self.continueButton.hideLoading()
//                }
//                //Order created
//                self.viewModel.cleanPaymentData()
//                let vc = OrderConfirmedViewController.instantiate(fromAppStoryboard: .Payment)
//                vc.modalPresentationStyle = .fullScreen
//                vc.viewModel.orderId = response.orderId
//                self.navigationController?.pushViewController(vc, animated: true)
//            })
//            .disposed(by: bag)
//    }
}


extension PaymentDataViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardNumberTextField {
            let maxLength = 16
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if textField == cvvTextField {
            let maxLength = 3
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
}

extension PaymentDataViewController: VerifyPaymentDelegate {
    func transactionValidation(with success: Bool, processId: String) {
        if success {
            if self.viewModel.isAccountPayment {
                self.getPaymentResult(with: processId)
            } else {
                self.getProductPaymentResult(with: processId)
            }
        } else {
            self.navigationController?.popViewController(animated: true, completion: {
                self.delegate?.errorWhilePayment(with: "Error en el proceso")
            })
        }
    }
}
