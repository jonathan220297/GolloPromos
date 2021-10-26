//
//  FilterViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import DropDown
import RxSwift

protocol FilterDelegate {
    func selectedStore(_ viewController: UIViewController, show selected: Bool)
}

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var allStoresLabel: UILabel!
    @IBOutlet weak var allStoresButton: UIButton!

    var delegate: FilterDelegate!
    var isStoreSelected: Bool = false

    lazy var viewModel: FilterViewModel = {
        return FilterViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        fetchFilters()
    }

    @IBAction func allStoresTapped(_ sender: Any) {
        let dropDown = DropDown()
        var options: [String] = ["Ver todas"]
//        for store in arrayStores {
//            options.append(store.nombre ?? "")
//        }
        dropDown.anchorView = allStoresButton
        dropDown.dataSource = options
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            allStoresLabel.text = item
            if index == 0 {
                isStoreSelected = false
            } else {
                isStoreSelected = true
            }
        }
    }

    // MARK:- Functions
    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloPromos", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchFilters() {
        viewModel.fetchFilterStores()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.filterData = data
            })
            .disposed(by: bag)
    }


}
