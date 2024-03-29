//
//  PaymentDataViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 18/8/22.
//

import UIKit
import RxSwift
import DropDown

class PaymentDataViewController: UIViewController {
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationMonthLabel: UILabel!
    @IBOutlet weak var expirationMonthButton: UIButton!
    @IBOutlet weak var expirationYearLabel: UILabel!
    @IBOutlet weak var expirationYearButton: UIButton!
    @IBOutlet weak var cardNameTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var continueButton: LoadingButton!
    
    lazy var viewModel: PaymentDataViewModel = {
        return PaymentDataViewModel()
    }()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "PaymentDataViewController_title".localized
        cardNumberTextField.delegate = self
        cvvTextField.delegate = self
        configureRx()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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
        cardNameTextField.rx.text.bind(to: viewModel.cardNameSubject).disposed(by: bag)
        cvvTextField.rx.text.bind(to: viewModel.cardCvvSubject).disposed(by: bag)
        viewModel.isValidForm.bind(to: continueButton.rx.isEnabled).disposed(by: bag)
        viewModel.isValidForm.map { $0 ? 1 : 0.4 }.bind(to: continueButton.rx.alpha).disposed(by: bag)
        
        continueButton.rx
            .tap
            .subscribe(onNext: {
//                self.setCardData()
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
