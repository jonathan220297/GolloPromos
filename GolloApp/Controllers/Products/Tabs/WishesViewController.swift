//
//  MenuTabDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/9/22.
//

import UIKit
import Nuke

class WishesViewController: UIViewController {

    @IBOutlet weak var whishesTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!

    var favorites: [Product] = []

    init() {
        super.init(nibName: "WishesViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Mis productos favoritos"
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favorites = CoreDataService().fetchFavoriteItems()
        if self.favorites.isEmpty {
            self.emptyView.alpha = 1
        } else {
            self.emptyView.alpha = 0
        }
        self.whishesTableView.reloadData()
    }

    func configureTableView() {
        self.whishesTableView.register(UINib(nibName: "WhishesTableViewCell", bundle: nil), forCellReuseIdentifier: "WhishesTableViewCell")
    }

}

extension WishesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getWhishesCell(tableView, cellForRowAt: indexPath)
    }

    func getWhishesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WhishesTableViewCell", for: indexPath) as? WhishesTableViewCell else {
            return UITableViewCell()
        }
        let product = self.favorites[indexPath.row]

        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        let url = URL(string: product.image ?? "")

        if let url = url {
            Nuke.loadImage(with: url, options: options, into: cell.productImageView)
        } else {
            cell.productImageView.image = UIImage(named: "empty_image")
        }
        cell.productNameLabel.text = favorites[indexPath.row].productName
        if let price = favorites[indexPath.row].precioFinal {
            let discountString = numberFormatter.string(from: NSNumber(value: price))!
            cell.productPriceLabel.text = "₡\(discountString)"
        }
        cell.selectionStyle = .none
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.modalPresentationStyle = .fullScreen
        vc.offer = favorites[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension WishesViewController: WhishesDelegate {
    func deleteItem(at indexPath: IndexPath) {
        let product = self.favorites[indexPath.row]
        let isFavorite = CoreDataService().isFavoriteProduct(with: product.productCode ?? "")
        if let id = isFavorite {
            let deleteItem = CoreDataService().deleteFavorite(with: id)
            if deleteItem {
                self.favorites = CoreDataService().fetchFavoriteItems()
                if self.favorites.isEmpty {
                    self.emptyView.alpha = 1
                } else {
                    self.emptyView.alpha = 0
                }
                self.whishesTableView.reloadData()
            }
        }
    }
}
