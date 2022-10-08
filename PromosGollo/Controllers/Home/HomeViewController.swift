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

class HomeViewController: UITabBarController {

    lazy var idealButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "defaultImage"), for: .normal)
        button.imageView?.layer.cornerRadius = 16
        button.imageView?.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.borderWidth = 1.5
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(buttonImageViewProfileTapped), for: .touchUpInside)
        return button
    }()

    @IBOutlet weak var homeTableView: UITableView!

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
        mainTab.title = "Inicio"
        mainTab.tabBarItem.image = UIImage(named: "")

        let offersTab = OffersTabViewController(
            viewModel: OffersTabViewModel()
        )
        offersTab.title = "Productos"
        offersTab.tabBarItem.image = UIImage(named: "ic_offer")

        let ordersTab = OrdersTabViewController(
            viewModel: OrdersTabViewModel()
        )
        ordersTab.title = "Ordenes"
        ordersTab.tabBarItem.image = UIImage(named: "ic_bag")

        let menuTab = MenuTabViewController()
        menuTab.title = "Más"
        menuTab.tabBarItem.image = UIImage(named: "ic_menu_home")

        viewControllers = [
            mainTab,
            offersTab,
            ordersTab,
            menuTab
        ]
    }

    func configureObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name("moveToCar"), object: nil, queue: nil) { _ in
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 2
            }
        }
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
