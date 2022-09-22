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
import XCGLogger
import CryptoKit
import AuthenticationServices

private let minimalUsernameLength = 5
private let minimalPasswordLength = 6

protocol LoginDelegate {
    func loginViewControllerShouldDismiss(_ loginViewController: LoginViewController)
}

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
    let userDefaults = UserDefaults.standard
    var currentNonce = ""
    var delegate: LoginDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        configureViews()
        configureRx()
        hideKeyboardWhenTappedAround()
        passwordTextField.enablePasswordToggle()
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
        let text = "No tienes una cuenta? REGISTRATE"
        signUpButton.setAttributedTitle(text.withBoldText(text: "REGISTRATE", fontNormalText: UIFont.sansSerifDemiBold(ofSize: 15), fontBoldText: UIFont.sansSerifBold(ofSize: 15), fontColorBold: .primary), for: .normal)
    }

    fileprivate func loginRequestInfo(for loginType: LoginType) {
        viewModel.fetchUserInfo(for: loginType)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let info = data.registro {
                    Variables.userProfile = info
                    do {
                        try self.userDefaults.setObject(info, forKey: "Information")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                Variables.isRegisterUser = data.estadoRegistro ?? false
                Variables.isLoginUser = data.estadoLogin ?? false
                Variables.isClientUser = data.estadoCliente ?? false
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

        forgotPasswordButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let vc = ResetPasswordViewController.instantiate(fromAppStoryboard: .Main)
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            })
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
                    self.showAlert(alertText: "GolloApp", alertMessage: "Please enter a valid email.")
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
                self.showAlert(alertText: "GolloApp", alertMessage: error)
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

    func appleLoginProcess() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // Generate nonce for validation after authentication successful
        self.currentNonce = randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = sha256(currentNonce)

        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.showAlert(alertText: "GolloApp", alertMessage: error.localizedDescription)
            return
        }

        guard let auth = user.authentication else {
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        authService.signIn(with: credential) { user, error in
            if let error = error {
                self.showAlert(alertText: "GolloApp", alertMessage: error)
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

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            // Save authorised user ID for future reference
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: self.currentNonce)

            // Sign in with Firebase
            authService.signIn(with: firebaseCredential) { user, error in
                if let error = error {
                    self.showAlert(alertText: "Shoppi", alertMessage: error)
                }
                guard let user = user else { return }
                // Mak a request to set user's display name on Firebase
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = appleIDCredential.fullName?.givenName
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Updated display name: \(Auth.auth().currentUser!.displayName!)")
                    }
                })
                self.viewModel.setUserData(with: user)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        log.debug("Sign in with Apple errored: \(error)")
        let nsError = error as NSError
        if nsError.code != 1001 {
            self.showAlert(alertText: "Shoppi", alertMessage: "Apple ID sign in error.")
        }
    }
}
