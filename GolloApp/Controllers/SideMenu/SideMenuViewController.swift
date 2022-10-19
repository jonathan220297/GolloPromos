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
    
    let disposeBag = DisposeBag()

    lazy var viewModel: SideMenuViewModel = {
        return SideMenuViewModel()
    }()

    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        if Variables.isRegisterUser {
            profileLabel.text = "Perfil de usuario"
        } else {
            profileLabel.text = "Registrar usuario"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserData()
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
            try firebaseAuth.signOut()
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            userDefaults.removeObject(forKey: "Information")
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
    fileprivate func setUserData() {
        if Variables.isRegisterUser {
            if let user = Variables.userProfile?.nombre,
               let lastname = Variables.userProfile?.apellido1 {
                    profileName.text = "\(user) \(lastname)"
            }
            if let email = Variables.userProfile?.correoElectronico1 {
                profileEmailLabel.text = email
            }
            if let url = URL(string: Variables.userProfile?.image ?? "") {
                Nuke.loadImage(with: url, into: profileImageView)
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
                self.openUrl("https://www.gollotienda.com/terminos-y-condiciones")
            })
            .disposed(by: disposeBag)
        
        helpButton
            .rx
            .tap
            .subscribe(onNext: {
                self.openUrl("https://www.gollotienda.com/contacto/")
            })
            .disposed(by: disposeBag)
    }
}

