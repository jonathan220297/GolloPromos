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

    // MARK: - Constants
    let defaults = UserDefaults.standard
    let viewModel: SearchOffersViewModel
    let bag = DisposeBag()

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
        self.searchBar.endEditing(true)
        viewModel.history = defaults.stringArray(forKey: "searchedText") ?? [String]()
        if viewModel.history.count > 0 {
            self.searchHistoryView.isHidden = false
            self.searchCollectionView.reloadData()
        } else {
            self.searchHistoryView.isHidden = true
        }
    }

    // MARK: - Observers
    @objc func reload() {
        guard let searchText = searchBar.text else { return }
        self.view.activityStarAnimating()
        if searchText != "" && searchText.count >= 3 {
            fetchOffers(with: searchText.lowercased())
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

    // MARK: - Functions
    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.view.activityStopAnimating()
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
                        productoDescription: ""
                    )
                    products.append(p)
                }
                self.viewModel.products = products
                self.collectionView.reloadData()

                if data.isEmpty {
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
            return CGSize(width: label.frame.width + 15, height: 30)
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
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == self.searchCollectionView {
            self.searchBar.text = viewModel.history[indexPath.row]
            self.fetchOffers(with: viewModel.history[indexPath.row])
        }
    }
}

extension SearchOffersViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchOffersViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
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

