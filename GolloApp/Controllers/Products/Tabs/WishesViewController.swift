//
//  MenuTabDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/9/22.
//

import UIKit

class WishesViewController: UIViewController {

    @IBOutlet weak var whishesTableView: UITableView!

    init() {
        super.init(nibName: "WishesViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Mis productos favoritos"
        configureTableView()
    }

    func configureTableView() {
        whishesTableView.register(UINib(nibName: "WhishesTableViewCell", bundle: nil), forCellReuseIdentifier: "WhishesTableViewCell")
    }

}

extension WishesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getWhishesCell(tableView, cellForRowAt: indexPath)
    }

    func getWhishesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WhishesTableViewCell", for: indexPath) as? WhishesTableViewCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
