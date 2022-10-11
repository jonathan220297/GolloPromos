//
//  MenuTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import UIKit

class MenuTabViewController: UIViewController {

    @IBOutlet weak var menuTabTableView: UITableView!

    var menuItems: [MenuTabData] = []

    init() {
        super.init(nibName: "MenuTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Menu"
        configureNavBar()
        configureTableView()
    }

    func configureTableView() {
        var firstItems: [ItemTabData] = []
        let accounts = ItemTabData(id: 1, image: "ic_menu_accounts", title: "Mis compras a crédito", subtitle: "Abonos y consultas a compras activas de crédito")
        let status = ItemTabData(id: 2, image: "ic_payment_status", title: "Estados de cuentas", subtitle: "Estado de cuentas a la fecha")
        let third = ItemTabData(id: 3, image: "ic_third_party_payment", title: "Compras a crédito activas de terceros", subtitle: "Abonos a compras activas de crédito de otras personas")
        let history = ItemTabData(id: 4, image: "ic_history", title: "Historial de pagos", subtitle: "Historial de pagos realizados por este App")
        firstItems.append(accounts)
        firstItems.append(status)
        firstItems.append(third)
        firstItems.append(history)
        let firstItem = MenuTabData(title: "Transacciones Gollo", items: firstItems)
        menuItems.append(firstItem)

        var secondItems: [ItemTabData] = []
        let whishes = ItemTabData(id: 5, image: "ic_heart", title: "Mis productos favoritos", subtitle: "Productos en mi lista de deseo")
        secondItems.append(whishes)
        let secondItem = MenuTabData(title: "Favoritos", items: secondItems)
        menuItems.append(secondItem)

        menuTabTableView.register(UINib(nibName: "MenuTabTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTabTableViewCell")
    }
    
}

extension MenuTabViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        menuItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuItems[section].title
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getMenuCell(tableView, cellForRowAt: indexPath)
    }

    func getMenuCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTabTableViewCell", for: indexPath) as? MenuTabTableViewCell else {
            return UITableViewCell()
        }
        cell.setMenuData(with: menuItems[indexPath.section].items[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let id = menuItems[indexPath.section].items[indexPath.row].id

        switch id {
        case 1:
            let accountsViewController = AccountsViewController.instantiate(fromAppStoryboard: .Payments)
            accountsViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(accountsViewController, animated: true)

        case 2:
            let statusViewController = StatusViewController.instantiate(fromAppStoryboard: .Payments)
            statusViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(statusViewController, animated: true)

        case 3:
            let thirdPartyViewController = ThirdPartyViewController.instantiate(fromAppStoryboard: .Payments)
            thirdPartyViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(thirdPartyViewController, animated: true)

        case 4:
            let historyViewController = HistoryViewController.instantiate(fromAppStoryboard: .Payments)
            historyViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(historyViewController, animated: true)

        case 5:
            let wishesViewController = WishesViewController()
            wishesViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(wishesViewController, animated: true)
            break

        default:
            print("Have you done something new?")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
