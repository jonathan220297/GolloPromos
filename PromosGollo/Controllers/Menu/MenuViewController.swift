//
//  MenuViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var menuTableView: UITableView!

    lazy var viewModel: MenuViewModel = {
        let vm = MenuViewModel()
        vm.initializeMenu()
        return vm
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    // MARK: - Functions
    fileprivate func configureTableView() {
        menuTableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTableViewCell")
        menuTableView.tableFooterView = UIView()
        menuTableView.reloadData()
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getMenuCell(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {

        } else if indexPath.row == 1 {
//            let vc = ProductsViewController.instantiate(fromAppStoryboard: .Products)
//            vc.modalPresentationStyle = .fullScreen
//            vc.viewModel.provenance = .whishlist
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func getMenuCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        cell.configureCell(with: viewModel.menuArray[indexPath.row])
        return cell
    }
}

