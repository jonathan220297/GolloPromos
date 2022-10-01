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
        configureTableView()
    }

    func configureTableView() {
        let whishes = MenuTabData(image: "ic_heart", title: "Mis productos favoritos", subtitle: "Productos en mi lista de deseo")
        menuItems.append(whishes)

        menuTabTableView.register(UINib(nibName: "MenuTabTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTabTableViewCell")
    }
    
}

extension MenuTabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getMenuCell(tableView, cellForRowAt: indexPath)
    }

    func getMenuCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTabTableViewCell", for: indexPath) as? MenuTabTableViewCell else {
            return UITableViewCell()
        }
        cell.setMenuData(with: menuItems[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let wishesViewController = WishesViewController()
        wishesViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(wishesViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
