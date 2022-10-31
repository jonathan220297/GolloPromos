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
import SafariServices

class SideMenuViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var termsConditionButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var notificationCountLabel: UILabel!
    
    let disposeBag = DisposeBag()

    lazy var viewModel: SideMenuViewModel = {
        return SideMenuViewModel()
    }()

    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureRx()
        if Variables.isRegisterUser {
            profileLabel.text = "Mi perfil"
        } else {
            profileLabel.text = "Registrar usuario"
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
        let firebaseAuth = Auth.auth()
        do {
            self.saveToken(with: "")
            try firebaseAuth.signOut()
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            userDefaults.removeObject(forKey: "Information")
            let _ = KeychainManager.delete(key: "token")
        } catch _ as NSError {
//            log.error("Error signing out: \(signOutError)")
        }
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
            if let user = Variables.userProfile?.nombre,
               let lastname = Variables.userProfile?.apellido1 {
                    profileName.text = "\(user) \(lastname)"
            }
            if let email = Variables.userProfile?.correoElectronico1 {
                profileEmailLabel.text = email
            }
            if let decodedData = Data(base64Encoded: Variables.userProfile?.image ?? ""),
               let decodedimage = UIImage(data: decodedData) {
                profileImageView.image = decodedimage
            } else {
                if let url = URL(string: Variables.userProfile?.image ?? "") {
                    Nuke.loadImage(with: url, into: profileImageView)
                }
            }
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
}

extension SideMenuViewController {
    // MARK: - Functions
    fileprivate func configureRx() {
        editProfileButton.rx.tap.bind {
            let vc = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
            vc.sideMenuAcction = true
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        .disposed(by: disposeBag)
        
        termsConditionButton
            .rx
            .tap
            .subscribe(onNext: {
                self.openUrl("https://servicios.grupogollo.com:9199/PromosArchivos/10-Unicomer%20de%20Costa%20Rica/02.Imagenes/DOC/Terminos-y-condiciones-App-de-Clientes.html")
            })
            .disposed(by: disposeBag)
        
        helpButton
            .rx
            .tap
            .subscribe(onNext: {
                self.openUrl("https://servicios.grupogollo.com:9199/PromosArchivos/10-Unicomer%20de%20Costa%20Rica/02.Imagenes/DOC/GOLLO-APP-Tutorial-de-uso.jpg")
            })
            .disposed(by: disposeBag)
    }
}

