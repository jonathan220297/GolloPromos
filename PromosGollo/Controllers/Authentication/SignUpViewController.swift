//
//  SignUpViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import RxCocoa
import RxSwift

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailConfirmationTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var signUpButton: LoadingButton!

    lazy var viewModel: SignUpViewModel = {
        return SignUpViewModel()
    }()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureRx()
        configureViews()
        hideKeyboardWhenTappedAround()
        passwordTextField.enablePasswordToggle()
        passwordConfirmationTextField.enablePasswordToggle()
    }
}

extension SignUpViewController {
    // MARK: - Functions
    fileprivate func configureViewModel() {
        viewModel.showConfirmationMessage = {[weak self] in
            self?.showConfirmationMessage()
        }

        viewModel.showError = {[weak self] message in
            self?.showAlert(alertText: "GolloApp", alertMessage: message)
        }

        viewModel.hideLoading = {[weak self] in
            guard let self = self else { return }
            self.signUpButton.hideLoading()
        }
    }

    fileprivate func configureRx() {
        emailTextField.rx.text.bind(to: viewModel.emailSubject).disposed(by: disposeBag)
        emailConfirmationTextField.rx.text.bind(to: viewModel.emailConfirmationSubject).disposed(by: disposeBag)
        passwordTextField.rx.text.bind(to: viewModel.passwordSubject).disposed(by: disposeBag)
        passwordConfirmationTextField.rx.text.bind(to: viewModel.passwordConfirmationSubject).disposed(by: disposeBag)
        viewModel.isValidForm.bind(to: signUpButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.isValidForm.map { $0 ? 1 : 0.4 }.bind(to: signUpButton.rx.alpha).disposed(by: disposeBag)
        signUpButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self,
                      let email = self.emailTextField.text,
                      let password = self.passwordTextField.text else { return }
                self.signUpButton.showLoading()
                self.viewModel.signUp(with: email, password)
            })
            .disposed(by: disposeBag)
    }

    fileprivate func showConfirmationMessage() {
        self.signUpButton.hideLoading()
        showAlertWithActions(alertText: "Verificación de correo", alertMessage: "Se enviará un enlace a tu correo electrónico para validar tu cuenta") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    fileprivate func configureViews() {
        emailTextField.setUnderLine()
        emailConfirmationTextField.setUnderLine()
        passwordTextField.setUnderLine()
        passwordConfirmationTextField.setUnderLine()
    }
}
