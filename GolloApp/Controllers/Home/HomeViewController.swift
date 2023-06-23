//
//  HomeViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import FirebaseAuth
import UIKit
import RxSwift
import Nuke
import ImageSlideshow
import FirebaseMessaging

protocol HomeDelegate: AnyObject {
    func showOfferDetail(_ offerDetail: UIViewController)
}

class HomeViewController: UITabBarController {
    // MARK: - IBOutlets
    @IBOutlet var carBarButton: UIBarButtonItem!
    
    let disposeBag = DisposeBag()
    let userDefaults = UserDefaults.standard
    
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateVersion()
        configureRx()
        configureTabBarAppearance()
        configureObservers()
    }

    // MARK: - Observers
    @objc func buttonImageViewProfileTapped() {
        if let vc = AppStoryboard.Menu.initialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: - Functions
    fileprivate func configureRx() {
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
                    self.showAlertWithActions(alertText: "GolloApp", alertMessage: "Tu sesión ha expirado y la aplicación se reiniciara inmediatamente.") {
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
        
        viewModel.updatedVersion
            .asObservable()
            .bind { (errorMessage) in
                if !errorMessage.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.showAlertWithActions(alertText: "Actualización", alertMessage: errorMessage) {
                            exit(0)
                        }
                    }
                    self.viewModel.updatedVersion.accept("")
                }
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func validateVersion() {
        self.view.activityStartAnimatingFull()
        Messaging.messaging().token { token, error in
          if let error = error {
              self.view.activityStopAnimatingFull()
              print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
              print("FCM registration token: \(token)")
              self.registerDevice(with: token)
          }
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
                    let _ = self.viewModel.saveToken(with: token)
                }
                if let deviceID = data.idCliente {
                    self.userDefaults.set(deviceID, forKey: "deviceID")
                }
                Variables.isRegisterUser = data.estadoRegistro ?? false
                Variables.isLoginUser = data.estadoLogin ?? false
                Variables.isClientUser = data.estadoCliente ?? false
                self.view.activityStopAnimatingFull()
                configureTabBar(with: data.indScanAndGo ?? false)
            })
            .disposed(by: disposeBag)
    }
    
    func configureTabBar(with scanActivated: Bool) {
        //Offers
        let homeTab = HomeTabViewController(
            viewModel: HomeViewModel()
        )
        let navigationMain = UINavigationController(rootViewController: homeTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationMain.navigationBar.standardAppearance = getNavBarAppareance()
        navigationMain.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationMain.title = "Inicio"
        navigationMain.tabBarItem.image = UIImage(named: "ic_new_home")

        let offersTab = OffersTabViewController(
            viewModel: OffersTabViewModel()
        )
        let navigationOffers = UINavigationController(rootViewController: offersTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationOffers.navigationBar.standardAppearance = getNavBarAppareance()
        navigationOffers.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationOffers.title = "Ofertas"
        navigationOffers.tabBarItem.image = UIImage(named: "ic_offer")

        let ordersTab = OrdersTabViewController(
            viewModel: OrdersTabViewModel()
        )
        let navigationOrders = UINavigationController(rootViewController: ordersTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationOrders.navigationBar.standardAppearance = getNavBarAppareance()
        navigationOrders.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationOrders.title = "Órdenes"
        navigationOrders.tabBarItem.image = UIImage(named: "ic_bag")
        
        let productScannerTab = ProductScannerViewController(
            viewModel: GolloStoresViewModel()
        )
        let navigationProductScanner = UINavigationController(rootViewController: productScannerTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationProductScanner.navigationBar.standardAppearance = getNavBarAppareance()
        navigationProductScanner.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationProductScanner.title = "Scan&Go"
        navigationProductScanner.tabBarItem.image = UIImage(systemName: "qrcode")

        let menuTab = MenuTabViewController()
        let navigationMenu = UINavigationController(rootViewController: menuTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationMenu.navigationBar.standardAppearance = getNavBarAppareance()
        navigationMenu.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationMenu.title = "Más"
        navigationMenu.tabBarItem.image = UIImage(named: "ic_menu_home")

        if scanActivated {
            viewControllers = [
                navigationMain,
                navigationOffers,
                navigationOrders,
                navigationProductScanner,
                navigationMenu
            ]
        } else {
            viewControllers = [
                navigationMain,
                navigationOffers,
                navigationOrders,
                navigationMenu
            ]
        }
    }

    func configureObservers() {
//        NotificationCenter.default.addObserver(forName: Notification.Name("moveToCar"), object: nil, queue: nil) { _ in
//            if let tabBarController = self.tabBarController {
//                tabBarController.selectedIndex = 2
//            }
//        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contactAction),
            name: NSNotification.Name(rawValue: "showContactInfo"),
            object: nil
        )
    }
    
    @objc func contactAction(notification: NSNotification) {
        contactFlow()
    }
    
    fileprivate func contactFlow() {
        let chatBotViewController = ChatbotViewController()
        chatBotViewController.modalPresentationStyle = .overCurrentContext
        chatBotViewController.modalTransitionStyle = .crossDissolve
        self.present(chatBotViewController, animated: true)
    }

    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor(named: "colorPrimary") ?? .blue], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
            tabBar.barTintColor = .white
        }
    }

    func getNavBarAppareance() -> UINavigationBarAppearance {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .primary
        // Create button appearance, with the custom color
        let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

        // Apply button appearance
        navBarAppearance.buttonAppearance = buttonAppearance
        return navBarAppearance
    }
}

extension HomeViewController: SignUpCellDelegate {
    func presentEditProfileController() {
        let vc = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: SignupWarningDelegate {
    func didTapSignupButton() {
        let editProfileViewController = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        editProfileViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
}
