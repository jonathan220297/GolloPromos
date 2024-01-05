//
//  FilterViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import DropDown
import RxSwift

protocol FilterOffersDelegate {
    func filterOffers(_ filterViewController: FilterViewController, reloadOffersFor store: StoreData)
}

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var allStoresLabel: UILabel!
    @IBOutlet weak var allStoresButton: UIButton!

    var delegate: FilterOffersDelegate?
    var isStoreSelected: Bool = false

    lazy var viewModel: FilterViewModel = {
        return FilterViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        configureTableView()
        fetchFilters()
    }

    @IBAction func allStoresTapped(_ sender: Any) {
        let dropDown = DropDown()
        let keys = Array(viewModel.groupStores.keys)
        var options: [String] = []
        for key in keys {
            options.append(key ?? "")
        }
        dropDown.anchorView = allStoresButton
        dropDown.dataSource = options
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            allStoresLabel.text = item
            self.viewModel.findStores(by: item) { _ in
                self.tableView.reloadData()
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
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureTableView() {
        tableView.tableFooterView = UIView()
    }

    fileprivate func fetchFilters() {
        viewModel.fetchFilterStores()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.filterData = data
                self.viewModel.groupStores(with: data)
                let keys = Array(self.viewModel.groupStores.keys)
                var options: [String] = []
                for key in keys {
                    options.append(key ?? "")
                }
                self.allStoresLabel.text = options.first ?? ""
                self.viewModel.findStores(by: options.first ?? "") { _ in
                    self.tableView.reloadData()
                }
            })
            .disposed(by: bag)
    }
}

extension FilterViewController: UITableViewDelegate,
                                UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.storesSelected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as! FilterTableViewCell
        cell.setFilterData(model: viewModel.storesSelected[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true, completion: {
            self.delegate?.filterOffers(self,
                                        reloadOffersFor: self.viewModel.storesSelected[indexPath.row])
        })
    }
}
