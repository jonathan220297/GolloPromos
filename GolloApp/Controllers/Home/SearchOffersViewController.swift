//
//  SearchOffersViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 14/10/22.
//

import UIKit
import RxSwift
import DropDown

class SearchOffersViewController: UIViewController {
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchHistoryView: UIView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchItemLabel: UILabel!
    @IBOutlet weak var suggestionsView: UIView!
    @IBOutlet weak var suggestionsTableView: UITableView!
    
    // MARK: - Constants
    let defaults = UserDefaults.standard
    let viewModel: SearchOffersViewModel
    let bag = DisposeBag()
    
    // MARK: - Constants
    var isShowing = false
    
    // MARK: - Lifecycle
    init(viewModel: SearchOffersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SearchOffersViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        configureTableView()
        hideKeyboardWhenTappedAround()
        
        self.searchBar.endEditing(true)
        viewModel.history = defaults.stringArray(forKey: "searchedText") ?? [String]()
        
        if viewModel.history.count > 0 {
            self.searchHistoryView.isHidden = false
            self.searchCollectionView.reloadData()
        } else {
            self.searchHistoryView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observers
    @objc func reload() {
        guard let searchText = searchBar.text else { return }
        self.view.activityStarAnimating()
        if searchText != "" && searchText.count >= 3 {
            fetchOffers(with: searchText.lowercased())
            fetchSuggestions(with: searchText.lowercased())
            var array = viewModel.history
            array.append(searchText)
            defaults.set(array, forKey: "searchedText")
            self.searchCollectionView.reloadData()
        } else {
            self.view.activityStopAnimating()
            self.emptyView.alpha = 1
            self.collectionView.alpha = 0
        }
    }
    
    @objc func keyboardWillAppear() {
        isShowing = true
        if !viewModel.suggestions.isEmpty {
            suggestionsView.isHidden = false
        }
    }

    @objc func keyboardWillDisappear() {
        isShowing = false
        suggestionsView.isHidden = true
    }
    
    // MARK: - Functions
    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.view.activityStopAnimating()
                    self.searchItemLabel.text = "No se encontraron productos"
                    self.emptyView.alpha = 1
                    self.collectionView.alpha = 0
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }
    
    func configureTableView() {
        self.searchCollectionView.register(UINib(nibName: "SearchHistoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchHistoryCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        suggestionsTableView.register(UINib(nibName: "SuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "SuggestionsTableViewCell")
    }
    
    fileprivate func fetchSuggestions(with searchText: String? = nil) {
        viewModel
            .fetchSuggestions(with: searchText)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                
                var suggestions: [LocalSuggestions] = []
                if let articles = data.articulos {
                    for a in articles {
                        suggestions.append(LocalSuggestions(id: a.idArticulo, name: a.nombre, image: a.urlImagen))
                    }
                }
                
                if let brands = data.marcas {
                    for b in brands {
                        suggestions.append(LocalSuggestions(id: nil, name: b.marca, image: nil))
                    }
                }
                
                self.viewModel.suggestions = suggestions
                self.suggestionsTableView.reloadData()
                
                if isShowing && !suggestions.isEmpty {
                    self.suggestionsView.isHidden = false
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchOffers(with searchText: String? = nil) {
        viewModel
            .fetchFilteredProducts(with: searchText)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimating()
                var products: [Product] = []
                for o in data {
                    let p = Product(
                        productCode: o.productCode,
                        descriptionDetailDescuento: o.descriptionDetailDescuento,
                        descriptionDetailRegalia: o.descriptionDetailRegalia,
                        originalPrice: o.originalPrice,
                        image: o.image,
                        montoBono: o.montoBono,
                        porcDescuento: o.porcDescuento,
                        brand: o.brand,
                        descriptionDetailBono: o.descriptionDetailRegalia,
                        tieneBono: o.tieneBono,
                        name: o.name,
                        modelo: o.modelo,
                        endDate: o.endDate,
                        tieneRegalia: o.tieneRegalia,
                        simboloMoneda: SimboloMoneda.empty,
                        id: o.id,
                        montoDescuento: o.montoDescuento,
                        idUsuario: o.idUsuario,
                        product: o.product,
                        idEmpresa: o.idempresa,
                        startDate: o.startDate,
                        precioFinal: o.precioFinal,
                        productName: o.productName,
                        tieneDescuento: o.tieneDescuento,
                        tipoPromoApp: 0,
                        productoDescription: "",
                        muestraDescuento: o.muestraDescuento,
                        tiene2x1: o.tiene2x1,
                        tieneNuevo: o.tieneNuevo,
                        tieneTopVentas: o.tieneTopVentas,
                        tieneExclusivo: o.tieneExclusivo,
                        tienetranspGratis: o.tienetranspGratis,
                        indMostrarTop: o.indMostrarTop
                    )
                    products.append(p)
                }
                self.viewModel.products = products
                self.collectionView.reloadData()
                
                if data.isEmpty {
                    self.searchItemLabel.text = "No se encontraron productos"
                    self.emptyView.alpha = 1
                    self.collectionView.alpha = 0
                } else {
                    self.emptyView.alpha = 0
                    self.collectionView.alpha = 1
                }
            })
            .disposed(by: bag)
    }
    
}
// MARK: - Extensions
extension SearchOffersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
        self.perform(#selector(reload), with: nil, afterDelay: 0.5)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchOffersViewController: UICollectionViewDelegate,
                                      UICollectionViewDataSource,
                                      UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return viewModel.products.count
        } else if collectionView == self.searchCollectionView {
            return viewModel.history.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            return getProductCell(collectionView, cellForItemAt: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchHistoryCollectionViewCell", for: indexPath) as! SearchHistoryCollectionViewCell
            cell.searchLabel.text = viewModel.history[indexPath.row]
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }
    }
    
    func getProductCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.setProductData(with: viewModel.products[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.searchCollectionView {
            let label = UILabel(frame: CGRect.zero)
            label.text = viewModel.history[indexPath.row]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 28, height: 40)
        } else {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
            vc.offer = viewModel.products[indexPath.row]
            vc.skuProduct = viewModel.products[indexPath.row].productCode
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == self.searchCollectionView {
            self.searchBar.text = viewModel.history[indexPath.row]
            self.fetchOffers(with: viewModel.history[indexPath.row])
            self.fetchSuggestions(with: viewModel.history[indexPath.row])
        }
    }
}

extension SearchOffersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getSuggestionCell(tableView, cellForRowAt: indexPath)
    }
    
    func getSuggestionCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionsTableViewCell", for: indexPath) as? SuggestionsTableViewCell else {
            return UITableViewCell()
        }
        cell.setSuggestionData(with: viewModel.suggestions[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}

extension SearchOffersViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchOffersViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchOffersViewController: SearchHistoryDelegate {
    func deleteItem(at indexPath: IndexPath) {
        self.viewModel.history.remove(at: indexPath.row)
        defaults.set(self.viewModel.history, forKey: "searchedText")
        self.searchCollectionView.reloadData()
        if viewModel.history.count > 0 {
            self.searchHistoryView.isHidden = false
        } else {
            self.searchHistoryView.isHidden = true
        }
    }
}

extension SearchOffersViewController: SuggestionsCellDelegate {
    func didSelectSuggestionOption(at indexPath: IndexPath) {
        let item = viewModel.suggestions[indexPath.row]
        if let sku = item.id, !sku.isEmpty {
            let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
            vc.skuProduct = sku
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.endEditing(true)
            self.searchBar.text = item.name
            self.fetchOffers(with: item.name?.lowercased())
            self.fetchSuggestions(with: item.name?.lowercased())
        }
    }
}
