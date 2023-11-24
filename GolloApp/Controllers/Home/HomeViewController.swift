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
import SafariServices

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
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                    }
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
        
        viewModel.updatedVersion
            .asObservable()
            .bind { (errorMessage) in
                if !errorMessage.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.showAlertWithActions(alertText: "Actualización", alertMessage: errorMessage) {
//                            exit(0)
                            self?.openUrl("https://apps.apple.com/us/app/gollo/id1643795423")
                        }
                    }
                    self.viewModel.updatedVersion.accept("")
                }
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func validateVersion() {
        DispatchQueue.main.async {
            self.view.activityStartAnimatingFull()
        }
        Messaging.messaging().token { token, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.activityStopAnimatingFull()
                }
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
                self.configureTabBar(with: data.indScanAndGo ?? false)
                DispatchQueue.main.async {
                    self.view.activityStopAnimatingFull()
                }
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
        navigationMain.tabBarItem.image = UIImage(named: "ic_bottom_menu_home")
        
        let categoriesTab = CategoriesViewController(
            viewModel: CategoriesViewModel()
        )
        let navigationOffers = UINavigationController(rootViewController: categoriesTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationOffers.navigationBar.standardAppearance = getNavBarAppareance()
        navigationOffers.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationOffers.title = "Categorías"
        navigationOffers.tabBarItem.image = UIImage(named: "ic_bottom_menu_categories")
        
        let ordersTab = OrdersTabViewController(
            viewModel: OrdersTabViewModel()
        )
        let navigationOrders = UINavigationController(rootViewController: ordersTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationOrders.navigationBar.standardAppearance = getNavBarAppareance()
        navigationOrders.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationOrders.title = "Órdenes"
        navigationOrders.tabBarItem.image = UIImage(named: "ic_bottom_menu_orders")
        
        let productScannerTab = ProductScannerViewController(
            viewModel: GolloStoresViewModel()
        )
        let navigationProductScanner = UINavigationController(rootViewController: productScannerTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationProductScanner.navigationBar.standardAppearance = getNavBarAppareance()
        navigationProductScanner.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationProductScanner.title = "Scan&Go"
        navigationProductScanner.tabBarItem.image = UIImage(named: "ic_bottom_menu_scan")
        
        let menuTab = MenuTabViewController()
        let navigationMenu = UINavigationController(rootViewController: menuTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationMenu.navigationBar.standardAppearance = getNavBarAppareance()
        navigationMenu.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationMenu.title = "Pagos"
        navigationMenu.tabBarItem.image = UIImage(named: "ic_bottom_menu_payments")
        
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
    
    func openUrl(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
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
            selector: #selector(homeAction),
            name: NSNotification.Name(rawValue: "showHomeAction"),
            object: nil
        )
        
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
    
    @objc func homeAction(notification: NSNotification) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
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
