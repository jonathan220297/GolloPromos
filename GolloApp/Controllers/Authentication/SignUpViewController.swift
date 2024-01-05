//
//  SignUpViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import FirebaseAuth
import RxCocoa
import RxSwift

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var signUpButton: LoadingButton!

    lazy var viewModel: SignUpViewModel = {
        return SignUpViewModel()
    }()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureRx()
        hideKeyboardWhenTappedAround()
        passwordTextField.enablePasswordToggle()
    }
}

extension SignUpViewController {
    // MARK: - Functions
    fileprivate func configureViewModel() {
        viewModel.showConfirmationMessage = {[weak self] in
            self?.showConfirmationMessage()
        }

        viewModel.showError = {[weak self] message in
            guard let self = self else { return }
            self.signUpButton.hideLoading()
            self.showAlert(alertText: "GolloApp", alertMessage: message)
        }

        viewModel.hideLoading = {[weak self] in
            guard let self = self else { return }
            self.signUpButton.hideLoading()
        }
    }

    fileprivate func configureRx() {
        emailTextField.rx.text.bind(to: viewModel.emailSubject).disposed(by: disposeBag)
        passwordTextField.rx.text.bind(to: viewModel.passwordSubject).disposed(by: disposeBag)
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
                self.viewModel.signUp(with: email.trimmingCharacters(in: .whitespacesAndNewlines), password)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .passwordErrorSubject
            .asObservable()
            .subscribe(onNext: {[weak self] value in
                guard let self = self, let value = value else { return }
                if value {
                    self.passwordErrorLabel.isHidden = false
                    self.passwordErrorLabel.text = "La clave debe tener al menos una letra mayúscula, una letra minúscula, un número, un caracter especial (@#$%^&+=), no debe poseer espacios en blanco y debe poseer un mínimo de 6 caracteres"
                } else {
                    self.passwordErrorLabel.isHidden = true
                    self.passwordErrorLabel.text = ""
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func showConfirmationMessage() {
        self.signUpButton.hideLoading()
        showAlertWithActions(alertText: "Verificación de correo", alertMessage: "Se enviará un enlace a tu correo electrónico para validar tu cuenta") {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                Variables.isRegisterUser = false
                Variables.isLoginUser = false
                Variables.isClientUser = false
                Variables.userProfile = nil
                UserManager.shared.userData = nil
            } catch let signOutError as NSError {
                log.error("Error signing out: \(signOutError)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
