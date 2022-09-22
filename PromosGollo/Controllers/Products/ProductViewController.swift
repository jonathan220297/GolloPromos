//
//  ProductViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/9/22.
//

import UIKit

class ProductViewController: UITabBarController {
    
    init() {
        super.init(nibName: "ProductViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    func configureTabBar() {
        //Offers
        let offersTab = OffersTabViewController(
            viewModel: OffersTabViewModel()
        )
        offersTab.title = "Offers"
        offersTab.tabBarItem.image = UIImage(named: "ic_offer")
        
        let productsTab = ProductsTabViewController()
        productsTab.title = "Products"
        productsTab.tabBarItem.image = UIImage(named: "ic_product")
        
        let carTab = CarTabViewController()
        carTab.title = "Car"
        carTab.tabBarItem.image = UIImage(named: "ic_car")
        
        let ordersTab = OrdersTabViewController()
        ordersTab.title = "My orders"
        ordersTab.tabBarItem.image = UIImage(named: "ic_bag")
        
        let menuTab = MenuTabViewController()
        menuTab.title = "Menu"
        menuTab.tabBarItem.image = UIImage(named: "ic_menu_home")
        
        viewControllers = [
            offersTab,
            productsTab,
            carTab,
            ordersTab,
            menuTab
        ]
    }
}
