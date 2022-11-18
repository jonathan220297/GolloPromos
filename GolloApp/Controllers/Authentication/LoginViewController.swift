//
//  LoginViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import RxSwift
import GoogleSignIn
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import XCGLogger
import CryptoKit
import AuthenticationServices

private let minimalUsernameLength = 5
private let minimalPasswordLength = 6

protocol LoginDelegate {
    func loginViewControllerShouldDismiss(_ loginViewController: LoginViewController)
    func didLoginSucceed()
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
        let text = "¿No tenés una cuenta? REGISTRATE"
        signUpButton.setAttributedTitle(text.withBoldText(text: "REGISTRATE", fontNormalText: UIFont.sansSerifDemiBold(ofSize: 15), fontBoldText: UIFont.sansSerifBold(ofSize: 15), fontColorBold: .primary), for: .normal)
    }

    fileprivate func loginRequestInfo(for loginType: LoginType) {
        guard let user = Auth.auth().currentUser else { return }
        user.getIDToken(completion: { (res, err) in
            if err != nil {
                print("*** TOKEN() ERROR: \(err!)")
            } else {
                print("*** TOKEN() SUCCESS: \(res!)")
                self.viewModel
                    .fetchUserInfo(for: loginType, idToken: res ?? "")
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
                        self.dismiss(animated: true) {
                            self.delegate?.didLoginSucceed()
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
        })
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

        let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        googleLoginButton
            .rx
            .tap
            .subscribe(onNext: { _ in
                GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) {[weak self] user, error in
                    guard let self = self else { return }
                    if let error = error as? NSError {
                        if error.code != -5 {
                            self.showAlert(alertText: "GolloApp", alertMessage: error.localizedDescription)
                        }
                        return
                    }

                    guard let auth = user?.authentication, let idToken = auth.idToken else {
                        return
                    }

                    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: auth.accessToken)
                    self.authService.signIn(with: credential) { user, error in
                        if let error = error {
                            self.showAlert(alertText: "GolloApp", alertMessage: error)
                        }
                        guard let user = user else { return }
                        self.viewModel.setUserData(with: user)
                        self.loginRequestInfo(for: .google)
                    }
                }
            })
            .disposed(by: disposeBag)
                
        facebookLoginButton
                .rx
                .tap
                .subscribe(onNext: {[weak self] in
                    guard let self = self else { return }
                    self.facebookLoginProcess()
                })
                .disposed(by: disposeBag)
                
        appleLoginButton
                .rx
                .tap
                .subscribe(onNext: {[weak self] in
                    guard let self = self else { return }
                    self.appleLoginProcess()
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
                if error == "Verify your email address" {
                    let refreshAlert = UIAlertController(title: "Verificación de email", message: "Su cuenta de correo aún no ha sido verificada. Para verificarla debe hacer click en el link enviado a su cuenta de correo; el correo puede estar en la bandeja de correos no deseados.", preferredStyle: UIAlertController.Style.alert)

                    refreshAlert.addAction(UIAlertAction(title: "Reenviar correo", style: .default, handler: { (action: UIAlertAction!) in
                        user?.reload()
                        if let user = user {
                            if !user.isEmailVerified {
                                user.sendEmailVerification { error in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        refreshAlert.dismiss(animated: true)
                    }))

                    refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
                        refreshAlert.dismiss(animated: true)
                    }))

                    self.present(refreshAlert, animated: true, completion: nil)
                } else {
                    var userError = error
                    if userError == "The password is invalid or the user does not have a password." {
                        userError = "Usuario y/o contraseña son inválidos."
                    }
                    self.showAlert(alertText: "GolloApp", alertMessage: userError)
                }
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
    
    func facebookLoginProcess() {
        let loginManager = LoginManager()
        let readPermissions: [Permission] = [.publicProfile, .email]
        loginManager.logIn(permissions: readPermissions, viewController: self, completion: didReceiveFacebookLoginResult)
    }

    private func didReceiveFacebookLoginResult(loginResult: LoginResult) {
        switch loginResult {
        case .success:
            didLoginWithFacebook()
        case .failed(_): break
        default: break
        }
    }

    fileprivate func didLoginWithFacebook() {
        // Successful log in with Facebook
        if let accessToken = AccessToken.current {
            viewModel.signIn(with: FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)) {[weak self] user, error in
                guard let self = self else { return }
                if let error = error {
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    do {
                        try Auth.auth().signOut()
                    } catch let error as NSError {
                        log.debug(error)
                    }
                }
                guard let user = user else { return }
                self.viewModel.setUserData(with: user)
                self.loginRequestInfo(for: .facebook)
            }
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
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                }
                guard let user = user else { return }
                // Mak a request to set user's display name on Firebase
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = appleIDCredential.fullName?.givenName
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                self.viewModel.setUserData(with: user)
                self.loginRequestInfo(for: .apple)
//                if let vc = AppStoryboard.Home.initialViewController() {
//                    vc.modalPresentationStyle = .fullScreen
//                    self.present(vc, animated: true)
//                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        log.debug("Sign in with Apple errored: \(error)")
        let nsError = error as NSError
        switch nsError.code {
        case 1001, 1000:
            break
        default:
            self.showAlert(alertText: "GolloApp", alertMessage: "Apple ID sign in error.")
        }
    }
}
