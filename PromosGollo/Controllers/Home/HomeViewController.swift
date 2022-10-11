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
    
    @objc func menuButtonTapped() {
        
    }
    
    @objc func carButtonTapped() {
        
    }

    // MARK: - Functions
    func configureTabBar() {
        //Offers
        let mainTab = MainViewController(
            viewModel: HomeViewModel()
        )
        mainTab.title = "Inicio"
        mainTab.tabBarItem.image = UIImage(systemName: "house.fill")

        let offersTab = OffersTabViewController(
            viewModel: OffersTabViewModel()
        )
        offersTab.title = "Ofertas"
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
        
        carBarButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                let carTab = CarTabViewController(
                    viewModel: CarTabViewModel()
                )
                carTab.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(carTab, animated: true)
            })
            .disposed(by: bag)
    }
    
//    func configureNavigationBarButtons() {
//        let menuButton = UIBarButtonItem(image: UIImage(systemName: "menucard.fill"), style: .plain, target: self, action: #selector(menuButtonTapped))
//        let carButton = UIBarButtonItem(image: UIImage(systemName: "bag.fill"), style: .plain, target: self, action: #selector(carButtonTapped))
//        tabBarController?.navigationController?.navigationItem.leftBarButtonItem = menuButton
//        tabBarController?.navigationController?.navigationItem.leftBarButtonItem = carButton
//    }

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
