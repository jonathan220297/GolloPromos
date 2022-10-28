//
//  ProductDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var accountType: String = ""
    var accountId: String = ""

    lazy var viewModel: AccountItemsViewModel = {
        return AccountItemsViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPopup.clipsToBounds = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true

        self.tableView.rowHeight = 70.0

        configureRx()
        fetchItems()
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

    // MARK: - Functions
    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                    self.emptyView.alpha = 1
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchItems() {
        view.activityStarAnimating()
        viewModel.fetchAccountItems(with: self.accountType, accountId: self.accountId)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                self.viewModel.items = data.articulos ?? []
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

}

extension ProductDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.viewModel.items.first {
            if let _ = data.precioUnitario, let _ = data.descripcion {
                self.emptyView.alpha = 0
                return self.viewModel.items.count
            } else {
                self.emptyView.alpha = 1
                return 0
            }
        } else {
            self.emptyView.alpha = 1
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.items[indexPath.row]
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

