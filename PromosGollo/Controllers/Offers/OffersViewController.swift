//
//  OffersViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import RxSwift
import DropDown

class OffersViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var closeFilterButton: UIButton!
    @IBOutlet weak var offersTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var scrollViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var offersTableViewHeightConstraint: NSLayoutConstraint!
    
    var dropButton = DropDown()
    
    // MARK: - Constants
    lazy var viewModel: OffersViewModel = {
        return OffersViewModel()
    }()
    let bag = DisposeBag()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        configureTableView()
        configureSearchBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Ofertas"
        fetchCategories()
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
                }
            })
            .disposed(by: bag)
        
        filtersButton
            .rx
            .tap
            .subscribe(onNext: {
                let vc = FilterViewController.instantiate(fromAppStoryboard: .Offers)
                vc.modalPresentationStyle = .fullScreen
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
        
        closeFilterButton
            .rx
            .tap
            .subscribe(onNext: {
                self.viewModel.filterSelected = false
                self.viewFilter.isHidden = !self.viewFilter.isHidden
                self.viewModel.idCategory = nil
                self.viewModel.idStore = nil
                self.fetchCategories()
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureTableView() {
        offersTableView.register(UINib(nibName: "CategoryOffersTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryOffersTableViewCell")
        offersTableView.register(UINib(nibName: "OffersTableViewCell", bundle: nil), forCellReuseIdentifier: "OffersTableViewCell")
        offersTableView.allowsSelection = false
        offersTableView.separatorStyle = .none
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
        
        dropButton.anchorView = searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y:(dropButton.anchorView?.plainView.bounds.height)!)
        dropButton.backgroundColor = .white
        dropButton.direction = .bottom
        dropButton.cellNib = UINib(nibName: "OffersQueryView", bundle: nil)
        dropButton.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? OffersQueryView else { return }

            // Setup your custom UI components
            cell.setData(with: self.viewModel.offersQueryFiltered[index].image ?? "",
                         self.viewModel.offersQueryFiltered[index].productCode ?? "")
            
        }
        
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            log.debug("Selected item: \(item) at index: \(index)") //Selected item: code at index: 0
            self.openDetail(with: self.viewModel.offersQueryFiltered[index])
        }
    }

    fileprivate func fetchCategories() {
        view.activityStarAnimating()
        viewModel.fetchCategories()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.categories = data
                self.fetchOffers()
            })
            .disposed(by: bag)
    }

    fileprivate func fetchOffers(with category: String? = nil) {
        viewModel
            .fetchOffers(with: category)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    self.viewModel.offers = data
                    self.viewModel.offersFilteres = self.viewModel.offers
                    if category == nil {
                        self.viewModel.processCategoryOrders { _ in
                            self.offersTableView.reloadData()
                            var height = 0
                            for category in self.viewModel.categoryOffers {
                                height += category.height
                            }
                            self.changeHeightScrollView(with: Double(height))
                        }
                    } else {
                        self.offersTableView.reloadData()
                        if self.viewModel.offersFilteres.count > 0 {
                            let height = round(Double(self.viewModel.offersFilteres.count / 2)) * 310
                            self.changeHeightScrollView(with: height)
                        } else {
                            let height = 100
                            self.changeHeightScrollView(with: Double(height))
                        }
                        
                    }
                }
                if data.isEmpty {
                    self.setEmptyView(with: "ic_offers_home", "OfferList", "No offers")
                    self.emptyView.isHidden = false
                } else {
                    self.emptyView.isHidden = true
                }
            })
            .disposed(by: bag)
    }

    fileprivate func changeHeightScrollView(with height: Double) {
        self.offersTableViewHeightConstraint.constant = CGFloat(height)
        self.scrollViewHeightConstraints.constant = CGFloat(height + 56 + (viewFilter.isHidden ? 0 : 50))
    }
    
    fileprivate func fetchStoreOffers(with storeID: String) {
        view.activityStarAnimating()
        viewModel
            .fetchOffersStores(with: storeID)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    self.viewModel.offers = data
                    self.viewModel.offersFilteres = self.viewModel.offers
                    self.offersTableView.reloadData()
                    let height = round(Double(self.viewModel.offersFilteres.count / 2)) * 310
                    self.changeHeightScrollView(with: height)
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func setEmptyView(with image: String,
                                  _ title: String,
                                  _ description: String) {
        let listEmptyView = EmptyTableView.instanceFromNib()
        listEmptyView.setEmptyData(with: image, title, description)
        self.emptyView.addSubview(listEmptyView)
        NSLayoutConstraint.activate([
            listEmptyView.topAnchor.constraint(equalTo: self.emptyView.topAnchor, constant: 0),
            listEmptyView.bottomAnchor.constraint(equalTo: self.emptyView.bottomAnchor, constant: 0),
            listEmptyView.trailingAnchor.constraint(equalTo: self.emptyView.trailingAnchor, constant: 0),
            listEmptyView.leadingAnchor.constraint(equalTo: self.emptyView.leadingAnchor, constant: 0)
        ])
    }
    
    fileprivate func fetchQueryOffers(with query: String,
                                      _ idCategory: String? = nil,
                                      _ idStore: String? = nil,
                                      completion: @escaping(_ result: Bool) -> ()) {
        viewModel
            .fetchQueryOffers(with: query, idCategory, idStore)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else {
                    completion(false)
                    return
                }
                self.viewModel.offersQuery = data
                self.viewModel.offersQueryFiltered = self.viewModel.offersQuery
                completion(true)
            })
            .disposed(by: bag)
    }
    
    func openDetail(with data: ProductsData) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OffersViewController: UITableViewDelegate,
                                UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.filterSelected {
            return 1
        } else {
            return viewModel.categoryOffers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.filterSelected {
            return getOffersCell(tableView, cellForRowAt: indexPath)
        } else {
            return getCategoryOffersCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.filterSelected {
            let height = round(Double(self.viewModel.offersFilteres.count / 2)) * 320
            return CGFloat(height)
        } else {
            return CGFloat(viewModel.categoryOffers[indexPath.row].height)
        }
    }
    
    func getCategoryOffersCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryOffersTableViewCell", for: indexPath) as! CategoryOffersTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        cell.viewModel.category = viewModel.categoryOffers[indexPath.row]
        cell.setViewsData()
        cell.configureCollectionView()
        cell.configureRx()
        return cell
    }
    
    func getOffersCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OffersTableViewCell", for: indexPath) as! OffersTableViewCell
        cell.delegate = self
        cell.viewModel.offersArray = viewModel.offersFilteres
        cell.configureCollectionView()
        return cell
    }
}

extension OffersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchQueryOffers(with: searchText, viewModel.idCategory, viewModel.idStore) { [self] result in
            if result {
                viewModel.offersQueryFiltered = searchText.isEmpty ? viewModel.offersQuery : viewModel.offersQuery.filter({ (dat) -> Bool in
                    dat.name?.range(of: searchText, options: .caseInsensitive) != nil
                })
                
                dropButton.dataSource = viewModel.offersQueryFiltered.map { ($0.name ?? "") }
                dropButton.show()
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        viewModel.offersQueryFiltered = viewModel.offersQuery
        dropButton.hide()
    }
}

extension OffersViewController: CategoryOffersDelegate {
    func categoryOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldMoveToDetailWith data: ProductsData) {
        openDetail(with: data)
    }
    
    func categoryOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldReloadOffersForCategoryAt indexPath: IndexPath) {
        log.debug("index: \(indexPath)")
        viewFilter.isHidden = !viewFilter.isHidden
        viewModel.filterSelected = true
        viewModel.idCategory = String(viewModel.categoryOffers[indexPath.row].category.idTipoCategoriaApp ?? 0)
        filterNameLabel.text = "Category = " + (viewModel.categoryOffers[indexPath.row].category.descripcion)
        fetchOffers(with: String(viewModel.categoryOffers[indexPath.row].category.idTipoCategoriaApp ?? 0))
    }
}

extension OffersViewController: FilterOffersDelegate {
    func filterOffers(_ filterViewController: FilterViewController, reloadOffersFor store: StoreData) {
        log.debug("store: \(store)")
        viewFilter.isHidden = !viewFilter.isHidden
        viewModel.filterSelected = true
        viewModel.idStore = store.idTienda ?? ""
        filterNameLabel.text = "Store = " + (store.nombre ?? "")
        fetchStoreOffers(with: store.idTienda ?? "")
    }
}

extension OffersViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: ProductsData) {
        openDetail(with: data)
    }
}
