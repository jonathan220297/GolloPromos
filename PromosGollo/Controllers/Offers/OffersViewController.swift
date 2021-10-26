//
//  OffersViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import RxSwift

class OffersViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var closeFilterButton: UIButton!
    @IBOutlet weak var filterHeight: NSLayoutConstraint!

    @IBOutlet weak var offersTableView: UITableView!
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Ofertas"
    }

    // MARK: - Functions
    func configureRx() {
    }
}

// MARK: - Extension Table View
extension OffersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let model = parentModel[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell

        //cell.setup(model: model)

        return cell.contentView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")

        return cell?.bounds.height ?? 50
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as! FooterTableViewCell

        cell.footerButton.addTarget(self, action: #selector(footerTapped(_ :)), for: .touchUpInside)
        cell.footerButton.tag = section

        if 1 < 3{
            return nil
        } else {
            return cell.contentView
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell")

        return cell?.bounds.height ?? 25
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return parentModel[section].children.count
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let model = parentModel[indexPath.section].children[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProductTableViewCell

        //cell.setOffers(offer: model!)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "offerDetailVC") as! OfferDetailViewController
        viewController.hidesBottomBarWhenPushed = true
        //viewController.offer = parentModel[indexPath.section].children[indexPath.row]
        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(viewController, animated: true)
    }

// MARK: - Table Views Observer
    @objc func footerTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "offerCategoryVC") as! OfferCategoryViewController
//        viewController.hidesBottomBarWhenPushed = true
//        viewController.category = self.parentModel[sender.tag].code
//        viewController.navigationItem.title = self.parentModel[sender.tag].name
//        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//        viewController.modalTransitionStyle = .crossDissolve
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
