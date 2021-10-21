//
//  ProductDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var tableView: UITableView!

    var accountType: String = ""
    var accountId: String = ""
    var arrayItems: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPopup.clipsToBounds = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true

        self.tableView.rowHeight = 70.0
        self.fetchItems()
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

    // MARK: - Functions
    fileprivate func fetchItems() {
//        let url = Constants.ipWS + "Procesos"
//        let parameters: [String :  Any] = [
//            "Servicio": [
//                "Encabezado": [
//                    "IdProceso": Constants.ACCOUNT_ITEMS_PROCESS_ID,
//                    "IdDevice": "",
//                    "IdUsuario": Constants.profile?.idUsuario ?? "",
//                    "TimeStamp": Date().timeIntervalSince1970,
//                    "IdCia": Constants.companyId,
//                    "token": Constants.tokenJWT
//                ],
//                "Parametros": [
//                    "empresa": String(Constants.companyId),
//                    "idCuenta": accountId,
//                    "tipoMovimiento": accountType
//                ]
//            ]
//        ]
//        MerckersService.getItems(url: url, parameters: parameters) { [self] (response) in
//            if let items = response?.articulos {
//                Helpers.debugOnConsole("Response Items Success: \(items)")
//                if !items.isEmpty {
//                    tableView.alpha = 1
//                    arrayItems = items
//                } else {
//                    tableView.alpha = 0
//                }
//
//                tableView.reloadData()
//                removeSpinner()
//            } else {
//                tableView.reloadData()
//                removeSpinner()
//                tableView.alpha = 0
//            }
//        }
    }

}

extension ProductDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = arrayItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsCell") as! ItemsTableViewCell

        cell.setItem(with: item)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProductDetailViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizer Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.viewGlass) {
            return true
        }
        return false
    }
}

