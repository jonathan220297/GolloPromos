//
//  LoginViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import RxSwift
import GoogleSignIn
import FirebaseAuth

private let minimalUsernameLength = 5
private let minimalPasswordLength = 5

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var buttonLogin: LoadingButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    lazy var viewModel: LoginViewModel = {
        return LoginViewModel()
    }()
    let authService = AuthenticationService()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        configureViews()
        configureRx()
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Functions
    fileprivate func configureViews() {
        let text = "Don't have an account? REGISTER"
        signUpButton.setAttributedTitle(text.withBoldText(text: "REGISTER", fontNormalText: UIFont.sansSerifDemiBold(ofSize: 15), fontBoldText: UIFont.sansSerifBold(ofSize: 15), fontColorBold: .primary), for: .normal)
    }

    fileprivate func loginRequestInfo(for loginType: LoginType) {
        viewModel.fetchUserInfo(for: loginType)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let vc = AppStoryboard.Home.initialViewController() {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func configureViewModel() {
        viewModel.hideLoading = {[weak self] in
            guard let self = self else { return }
            self.buttonLogin.hideLoading()
        }
    }

    fileprivate func configureRx() {
        let usernameValidation = usernameTextField
            .rx
            .text
            .orEmpty
            .map { $0.count >= minimalUsernameLength }
            .share(replay: 1)

        let passwordValidation = passwordTextField
            .rx
            .text
            .orEmpty
            .map { $0.count >= minimalPasswordLength }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(usernameValidation, passwordValidation) { $0 && $1}
            .share(replay: 1)

        everythingValid
            .bind(to: buttonLogin.rx.isEnabled)
            .disposed(by: disposeBag)

        everythingValid
            .map { $0 ? 1 : 0.4 }
            .bind(to: buttonLogin.rx.alpha)
            .disposed(by: disposeBag)

        buttonLogin
            .rx
            .tap
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.usernameTextField.resignFirstResponder()
                self.passwordTextField.resignFirstResponder()
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.isEmailValid(with: self.usernameTextField.text ?? "") {
                    self.doLogin(for: .email)
                } else {
                    self.showAlert(alertText: "GolloPromos", alertMessage: "Please enter a valid email.")
                }
            })
            .disposed(by: disposeBag)

        googleLoginButton
            .rx
            .tap
            .subscribe(onNext: { _ in
                GIDSignIn.sharedInstance().signIn()
            })
            .disposed(by: disposeBag)
    }

    func doLogin(for loginType: LoginType) {
        buttonLogin.showLoading()
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else { return }
        viewModel.signIn(with: username, password: password) {[weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                self.buttonLogin.hideLoading()
                self.showAlert(alertText: "GolloPromos", alertMessage: error)
                do {
                    try Auth.auth().signOut()
                } catch let error as NSError {
                    log.debug(error)
                }
            }
            guard let user = user else { return }
            self.viewModel.setUserData(with: user)
            self.loginRequestInfo(for: loginType)
        }
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.showAlert(alertText: "GolloPromos", alertMessage: error.localizedDescription)
            return
        }

        guard let auth = user.authentication else {
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        authService.signIn(with: credential) { user, error in
            if let error = error {
                self.showAlert(alertText: "GolloPromos", alertMessage: error)
            }
            guard let user = user else { return }
            self.viewModel.setUserData(with: user)
            if let vc = AppStoryboard.Home.initialViewController() {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
}
