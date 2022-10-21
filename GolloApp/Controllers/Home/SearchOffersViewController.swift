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
    
    // MARK: - Constants
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
        configureTableView()
    }

    // MARK: - Functions
    func configureTableView() {
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
    }

    fileprivate func fetchOffers(with searchText: String? = nil) {
        view.activityStarAnimating()
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
        if searchText != "" && searchText.count >= 3 {
            fetchOffers(with: searchText.lowercased())
        } else {
            self.emptyView.alpha = 1
            self.collectionView.alpha = 0
        }
    }
}

extension SearchOffersViewController: UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getProductCell(collectionView, cellForItemAt: indexPath)
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
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = viewModel.products[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
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

