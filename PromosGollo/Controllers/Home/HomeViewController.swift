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

protocol HomeDelegate: AnyObject {
    func showOfferDetail(_ offerDetail: UIViewController)
}

class HomeViewController: UITabBarController {
    // MARK: - IBOutlets
    @IBOutlet var carBarButton: UIBarButtonItem!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }

    // MARK: - Observers
    @objc func buttonImageViewProfileTapped() {
        if let vc = AppStoryboard.Menu.initialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: - Functions
    func configureTabBar() {
        //Offers
        let mainTab = MainViewController(
            viewModel: HomeViewModel()
        )
        let navigationMain = UINavigationController(rootViewController: mainTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationMain.navigationBar.standardAppearance = getNavBarAppareance()
        navigationMain.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationMain.title = "Inicio"
        navigationMain.tabBarItem.image = UIImage(systemName: "house.fill")

        let offersTab = OffersTabViewController(
            viewModel: OffersTabViewModel()
        )
        let navigationOffers = UINavigationController(rootViewController: offersTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationOffers.navigationBar.standardAppearance = getNavBarAppareance()
        navigationOffers.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationOffers.title = "Productos"
        navigationOffers.tabBarItem.image = UIImage(named: "ic_offer")

        let ordersTab = OrdersTabViewController(
            viewModel: OrdersTabViewModel()
        )
        let navigationOrders = UINavigationController(rootViewController: ordersTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationOrders.navigationBar.standardAppearance = getNavBarAppareance()
        navigationOrders.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationOrders.title = "Ordenes"
        navigationOrders.tabBarItem.image = UIImage(named: "ic_bag")

        let menuTab = MenuTabViewController()
        let navigationMenu = UINavigationController(rootViewController: menuTab)
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationMenu.navigationBar.standardAppearance = getNavBarAppareance()
        navigationMenu.navigationBar.scrollEdgeAppearance = getNavBarAppareance()
        navigationMenu.title = "Más"
        navigationMenu.tabBarItem.image = UIImage(named: "ic_menu_home")

        viewControllers = [
            navigationMain,
            navigationOffers,
            navigationOrders,
            navigationMenu
        ]
    }

    func configureObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name("moveToCar"), object: nil, queue: nil) { _ in
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 2
            }
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
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: SignupWarningDelegate {
    func didTapSignupButton() {
        let editProfileViewController = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        editProfileViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
}
