//
//  OffersFilteredListViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/10/22.
//

import UIKit
import RxSwift
import DropDown

class OffersFilteredListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    // MARK: - Constants
    let viewModel: OffersFilteredListViewModel
    let bag = DisposeBag()
    let category: Int?
    let taxonomy: Int

    // MARK: - Variables
    var lastIndexActive: IndexPath = [1, 0]
    var selectedPosition: Int = 0
    var selectedTaxonomy: Int = -1

    // MARK: - Lifecycle
    init(viewModel: OffersFilteredListViewModel, category: Int?, taxonomy: Int) {
        self.viewModel = viewModel
        self.category = category
        self.taxonomy = taxonomy
        super.init(nibName: "OffersFilteredListViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAlternativeNavBar()
        fetchCategories()
        fetchOffers(with: taxonomy)
        configureRx()
    }

    // MARK: - Functions
    func configureTableView() {
        self.collectionView.register(UINib(nibName: "CategoriesFilteredListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesFilteredListCell")
        self.productCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
    }

    fileprivate func configureRx() {
        optionButton.rx
            .tap
            .subscribe(onNext: {
                self.dropDown()
            })
            .disposed(by: bag)
    }

    fileprivate func fetchCategories() {
        var filterCategory: String?
        if let category = category {
            filterCategory = String(category)
        } else {
            filterCategory = nil
        }
        view.activityStarAnimating()
        viewModel
            .fetchFilteredCategories(with: filterCategory, taxonomy: taxonomy)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimating()
                self.viewModel.categories = data
                self.collectionView.reloadData()

                if data.isEmpty {
                    self.collectionView.isHidden = true
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchOffers(with taxonomy: Int = -1, order: Int? = nil) {
        var filterCategory: String?
        if let category = category {
            filterCategory = String(category)
        } else {
            filterCategory = nil
        }
        viewModel
            .fetchFilteredProducts(with: filterCategory, taxonomy: taxonomy, order: order)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
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
                    self.productCollectionView.reloadData()
                }
            })
            .disposed(by: bag)
    }

    fileprivate func dropDown() {
        let options = ["A-Z", "Z-A", "Menor precio", "Mayor precio"]
        let dropDown = DropDown()
        dropDown.anchorView = optionButton
        dropDown.dataSource = options
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            selectedPosition = index
            optionLabel.text = item
            self.fetchOffers(with: taxonomy, order: selectedPosition + 1)
        }
    }

}

extension OffersFilteredListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return viewModel.categories.count
        } else if collectionView == self.productCollectionView {
            return viewModel.products.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesFilteredListCell", for: indexPath) as! CategoriesFilteredListCollectionViewCell
            cell.titleLabel.text = viewModel.categories[indexPath.row].nombre
            return cell
        } else {
            return getProductCell(collectionView, cellForItemAt: indexPath)
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
        if collectionView == self.collectionView {
            return CGSize(width: 140, height: 35)
        } else {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 300)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            if self.lastIndexActive != indexPath {
                let selected = collectionView.cellForItem(at: indexPath) as! CategoriesFilteredListCollectionViewCell
                selected.titleLabel.textColor = .white
                selected.cellView.backgroundColor = .primaryLight
                selected.cellView.layer.cornerRadius = 10
                selected.cellView.layer.masksToBounds = true
                selected.cellView.layoutSubviews()
                selected.cellView.layoutIfNeeded()
                
                self.selectedTaxonomy = viewModel.categories[indexPath.row].idTipoCategoriaApp ?? -1
                self.fetchOffers(with: viewModel.categories[indexPath.row].idTipoCategoriaApp ?? -1)
                
                let previous = collectionView.cellForItem(at: lastIndexActive) as? CategoriesFilteredListCollectionViewCell
                previous?.titleLabel.textColor = UIColor { tc in
                    switch tc.userInterfaceStyle {
                    case .dark:
                        return UIColor.primary
                    default:
                        return UIColor.white
                    }
                }
                previous?.cellView.backgroundColor = .primary
                selected.cellView.layer.cornerRadius = 10
                selected.cellView.layer.masksToBounds = true
                selected.cellView.layoutSubviews()
                selected.cellView.layoutIfNeeded()
                
                self.lastIndexActive = indexPath
            }
        }
    }
}

extension OffersFilteredListViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OffersFilteredListViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}