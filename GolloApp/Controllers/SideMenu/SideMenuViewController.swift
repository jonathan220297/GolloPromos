//
//  SideMenuViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import Nuke
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseMessaging
import SafariServices

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var hideMenuButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profileChangeImage: UIImageView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var termsConditionButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var scanGoButton: UIButton!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoutView: UIView!
    
    let disposeBag = DisposeBag()
    
    lazy var viewModel: SideMenuViewModel = {
        return SideMenuViewModel()
    }()
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureRx()
        if Auth.auth().currentUser != nil {
            logoutView.backgroundColor = .blueLight
            logoutButton.isEnabled = true
            if Variables.isRegisterUser {
                profileLabel.text = "Perfil"
            } else {
                profileLabel.text = "Crea tu perfil"
            }
        } else {
            logoutView.backgroundColor = .lightGray
            logoutButton.isEnabled = false
            profileLabel.text = "Abrir sesión"
            profileChangeImage.image = UIImage(named: "ic_side_menu_new_session")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserData()
        fetchUnreadNotifications()
    }
    
    // MARK: - Actions
    @IBAction func notificationsButtonTapped(_ sender: Any) {
        let vc = NotificationsViewController.instantiate(fromAppStoryboard: .Notifications)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func openCategoriesTapped(_ sender: Any) {
        let categoriesViewController = CategoriesViewController(
            viewModel: CategoriesViewModel()
        )
        categoriesViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(categoriesViewController, animated: true)
    }
    
    // MARK: - Functions
    fileprivate func configureViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    fileprivate func setUserData() {
        if Variables.isRegisterUser {
            if let user = Variables.userProfile?.nombre {
                profileName.text = "Hola \(user.capitalized)"
            }
            if let email = Variables.userProfile?.correoElectronico1 {
                profileEmailLabel.text = email
            } else {
                profileEmailLabel.text = " "
            }
            if let decodedData = Data(base64Encoded: Variables.userProfile?.image ?? ""),
               let decodedimage = UIImage(data: decodedData) {
                profileImageView.image = decodedimage
            } else {
                if let url = URL(string: Variables.userProfile?.image ?? "") {
                    Nuke.loadImage(with: url, into: profileImageView)
                } else {
                    profileImageView.image = UIImage(named: "ic_side_menu_profile")
                    profileImageView.image?.withTintColor(.white)
                }
            }
        } else {
            profileName.text = nil
            profileEmailLabel.text = " "
            profileImageView.image = UIImage(named: "ic_side_menu_profile")
            profileImageView.image?.withTintColor(.white)
        }
    }
    
    func openUrl(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    func fetchUnreadNotifications() {
        viewModel
            .fetchUnreadNotifications()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let count = data.cantidad, count > 0 {
                    self.notificationCountLabel.isHidden = false
                    self.notificationCountLabel.text = "\(count)"
                } else {
                    self.notificationCountLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    func saveToken(with token: String) -> Bool {
        if let data = token.data(using: .utf8) {
            let status = KeychainManager.save(key: "token", data: data)
            log.debug("Status: \(status)")
            return true
        } else {
            return false
        }
    }
    
    fileprivate func registerDevice(with token: String) {
        viewModel
            .registerDevice(with: token)
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
                if let token = data.token {
                    let _ = KeychainManager.delete(key: "token")
                    let _ = self.viewModel.saveToken(with: token)
                }
                if let deviceID = data.idCliente {
                    self.userDefaults.set(deviceID, forKey: "deviceID")
                }
                Variables.isRegisterUser = data.estadoRegistro ?? false
                Variables.isLoginUser = data.estadoLogin ?? false
                Variables.isClientUser = data.estadoCliente ?? false
                self.showAlertWithActions(alertText: "GolloApp", alertMessage: "Sesión cerrada exitosamente") {
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension SideMenuViewController {
    // MARK: - Functions
    fileprivate func configureRx() {
        editProfileButton
            .rx
            .tap
            .bind {
                if Auth.auth().currentUser != nil {
                    let vc = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
                    vc.sideMenuAcction = true
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
                    let loginVC = vc.viewControllers.first as? LoginViewController
                    loginVC?.delegate = self
                    self.present(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel
            .errorExpiredToken
            .asObservable()
            .subscribe(onNext: {[weak self] value in
                guard let self = self,
                      let value = value else { return }
                if value {
                    self.view.activityStopAnimating()
                    self.viewModel.errorExpiredToken.accept(nil)
                    self.userDefaults.removeObject(forKey: "Information")
                    let _ = KeychainManager.delete(key: "token")
                    Variables.isRegisterUser = false
                    Variables.isLoginUser = false
                    Variables.isClientUser = false
                    Variables.userProfile = nil
                    UserManager.shared.userData = nil
                    self.showAlertWithActions(alertText: "Detectamos otra sesión activa", alertMessage: "La aplicación se reiniciará.") {
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            self.userDefaults.removeObject(forKey: "Information")
                            Variables.isRegisterUser = false
                            Variables.isLoginUser = false
                            Variables.isClientUser = false
                            Variables.userProfile = nil
                            UserManager.shared.userData = nil
                            Messaging.messaging().token { token, error in
                                if let error = error {
                                    print("Error fetching FCM registration token: \(error)")
                                } else if let token = token {
                                    self.registerDevice(with: token)
                                }
                            }
                        } catch let signOutError as NSError {
                            log.error("Error signing out: \(signOutError)")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        homeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
                NotificationCenter.default.post(name: Notification.Name("showHomeAction"), object: nil)
            })
            .disposed(by: disposeBag)
        
        searchButton
            .rx
            .tap
            .subscribe(onNext: {
                let searchOffersViewController = SearchOffersViewController(
                    viewModel: SearchOffersViewModel()
                )
                searchOffersViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(searchOffersViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        hideMenuButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        carButton
            .rx
            .tap
            .subscribe(onNext: {
                let carTab = CarTabViewController(
                    viewModel: CarTabViewModel()
                )
                carTab.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(carTab, animated: true)
            })
            .disposed(by: disposeBag)
        
        favoriteButton
            .rx
            .tap
            .subscribe(onNext: {
                let wishesViewController = WishesViewController()
                wishesViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(wishesViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        termsConditionButton
            .rx
            .tap
            .subscribe(onNext: {
                self.openUrl("https://servicios.grupogollo.com:9196/PromosArchivos/10-Unicomer%20de%20Costa%20Rica/02.Imagenes/DOC/Terminos-y-condiciones-App-de-Clientes.html")
            })
            .disposed(by: disposeBag)
        
        helpButton
            .rx
            .tap
            .subscribe(onNext: {
                self.openUrl("https://servicios.grupogollo.com:9196/PromosArchivos/10-Unicomer%20de%20Costa%20Rica/02.Imagenes/DOC/GOLLO-APP-Tutorial-de-uso.png")
            })
            .disposed(by: disposeBag)
        
        contactUsButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
                NotificationCenter.default.post(name: Notification.Name("showContactInfo"), object: nil)
            })
            .disposed(by: disposeBag)
        
        scanGoButton
            .rx
            .tap
            .subscribe(onNext: {
                let productScannerViewController = ProductScannerViewController(
                    viewModel: GolloStoresViewModel()
                )
                productScannerViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(productScannerViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        logoutButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    self.userDefaults.removeObject(forKey: "Information")
                    Variables.isRegisterUser = false
                    Variables.isLoginUser = false
                    Variables.isClientUser = false
                    Variables.userProfile = nil
                    UserManager.shared.userData = nil
                    Messaging.messaging().token { token, error in
                        if let error = error {
                            print("Error fetching FCM registration token: \(error)")
                        } else if let token = token {
                            self.registerDevice(with: token)
                        }
                    }
                } catch let signOutError as NSError {
                    log.error("Error signing out: \(signOutError)")
                }
            })
            .disposed(by: disposeBag)
    }
}

extension SideMenuViewController: LoginDelegate {
    func loginViewControllerShouldDismiss(_ loginViewController: LoginViewController) { }
    
    func didLoginSucceed() {
        self.dismiss(animated: true)
    }
}
