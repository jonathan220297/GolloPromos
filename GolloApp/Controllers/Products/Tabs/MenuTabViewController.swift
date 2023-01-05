//
//  MenuTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import FirebaseAuth
import UIKit

class MenuTabViewController: UIViewController {

    @IBOutlet weak var menuTabTableView: UITableView!

    var menuItems: [MenuTabData] = []
    var itemSelected: IndexPath = IndexPath(row: 0, section: 0)

    init() {
        super.init(nibName: "MenuTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Menu"
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        configureNavBar()
    }

    func configureTableView() {
        var firstItems: [ItemTabData] = []
        let accounts = ItemTabData(id: 1, image: "ic_menu_accounts", title: "Pago de cuotas", subtitle: "Abonos y consultas a compras activas de crédito")
        let status = ItemTabData(id: 2, image: "ic_payment_status", title: "Estados de cuentas", subtitle: "Estado de cuentas a la fecha")
        let third = ItemTabData(id: 3, image: "ic_third_party_payment", title: "Pago de cuotas de terceros", subtitle: "Abonos a compras activas de crédito de otras personas")
        let history = ItemTabData(id: 4, image: "ic_history", title: "Historial de pagos", subtitle: "Historial de pagos realizados por este App")
        firstItems.append(accounts)
        firstItems.append(status)
        firstItems.append(third)
        firstItems.append(history)
        let firstItem = MenuTabData(title: "Transacciones Gollo", items: firstItems)
        menuItems.append(firstItem)

        var secondItems: [ItemTabData] = []
        let whishes = ItemTabData(id: 5, image: "ic_heart", title: "Mis productos favoritos", subtitle: "Productos en mi lista de deseos")
        secondItems.append(whishes)
        let secondItem = MenuTabData(title: "Favoritos", items: secondItems)
        menuItems.append(secondItem)

        menuTabTableView.register(UINib(nibName: "MenuTabTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTabTableViewCell")
    }
    
    func moveToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
        let loginVC = vc.viewControllers.first as? LoginViewController
        loginVC?.delegate = self
        self.present(vc, animated: true)
    }
    
    func moveToProfile() {
        let editProfileViewController = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        editProfileViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    func moveToAccount() {
        if Variables.isRegisterUser {
            let accountsViewController = AccountsViewController.instantiate(fromAppStoryboard: .Payments)
            accountsViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(accountsViewController, animated: true)
        } else {
           moveToProfile()
        }
    }
    
    func moveToStatus() {
        if Variables.isRegisterUser {
            let statusViewController = StatusViewController.instantiate(fromAppStoryboard: .Payments)
            statusViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(statusViewController, animated: true)
        } else {
            moveToProfile()
        }
    }
    
    func moveToThirdParty() {
        if Variables.isRegisterUser {
            let thirdPartyViewController = ThirdPartyViewController.instantiate(fromAppStoryboard: .Payments)
            thirdPartyViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(thirdPartyViewController, animated: true)
        } else {
            moveToProfile()
        }
    }
    
    func moveToHistory() {
        if Variables.isRegisterUser {
            let historyViewController = HistoryViewController.instantiate(fromAppStoryboard: .Payments)
            historyViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(historyViewController, animated: true)
        } else {
            moveToProfile()
        }
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
        return menuItems[section].title.capitalized
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let titleView = view as! UITableViewHeaderFooterView
        titleView.textLabel?.text =  titleView.textLabel?.text?.capitalized
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
        itemSelected = indexPath
        let id = menuItems[indexPath.section].items[indexPath.row].id

        switch id {
        case 1:
            if Auth.auth().currentUser != nil {
                moveToAccount()
            } else {
                moveToLogin()
            }
        case 2:
            if Auth.auth().currentUser != nil {
                moveToStatus()
            } else{
                moveToLogin()
            }
        case 3:
            if Auth.auth().currentUser != nil {
                moveToThirdParty()
            } else {
                moveToLogin()
            }
        case 4:
            if Auth.auth().currentUser != nil {
                moveToHistory()
            } else {
                moveToLogin()
            }
        case 5:
            let wishesViewController = WishesViewController()
            wishesViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(wishesViewController, animated: true)
        default:
            print("Have you done something new?")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension MenuTabViewController: LoginDelegate {
    func loginViewControllerShouldDismiss(_ loginViewController: LoginViewController) { }
    
    func didLoginSucceed() {
        switch itemSelected.row {
        case 0:
            moveToAccount()
        case 1:
            moveToStatus()
        case 2:
            moveToThirdParty()
        case 3:
            moveToHistory()
        default: break
        }
    }
}
