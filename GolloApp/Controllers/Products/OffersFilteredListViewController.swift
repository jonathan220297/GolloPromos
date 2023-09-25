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
    
    @IBOutlet weak var categoriesContentView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var productsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    // MARK: - Constants
    let viewModel: OffersFilteredListViewModel
    let bag = DisposeBag()
    let category: Int?
    let taxonomy: Int
    
    // MARK: - Variables
    var lastIndexActive: IndexPath = [1, 0]
    var selectedPosition: Int = -1
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
        configureViews()
        configureTableView()
        fetchCategories()
        fetchOffers(with: taxonomy)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAlternativeNavBar()
        configureRx()
    }
    
    // MARK: - Functions
    func configureViews() {
        //        categoriesView.clipsToBounds = true
        //        categoriesView.layer.cornerRadius = 10
        //        categoriesView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        productsView.clipsToBounds = true
        productsView.layer.cornerRadius = 10
        productsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        optionView.clipsToBounds = true
        optionView.backgroundColor = .white
        optionView.layer.cornerRadius = 8
        optionView.layer.borderWidth = 1
        optionView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func configureTableView() {
        collectionView.register(UINib(nibName: "SectionCollectionViewCell", bundle: nil), forSupplementaryViewOfKind:
                                    UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionCollectionViewCell")
        collectionView.register(UINib(nibName: "CategoriesFilteredListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesFilteredListCell")
        productCollectionView.register(UINib(nibName: "SectionCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionCollectionViewCell")
        productCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
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
                    self.categoriesContentView.isHidden = true
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
                    self.viewModel.fetchingMore = false
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
                            indMostrarTop: o.indMostrarTop,
                            idCategoria2: o.idCategoria2
                        )
                        products.append(p)
                    }
                    if self.viewModel.page == 1 {
                        self.viewModel.products = products
                    } else {
                        self.viewModel.products.append(contentsOf: products)
                    }
                    self.viewModel.configureSections()
                    self.productCollectionView.reloadData()
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureViewModel() {
        viewModel.reloadTableViewData = { [weak self] in
            guard let self = self else { return }
            self.productCollectionView.reloadData()
        }
    }
    
    fileprivate func dropDown() {
        var newTaxonomy = taxonomy
        if selectedTaxonomy != -1 {
            newTaxonomy = selectedTaxonomy
        }
        let options = ["Nombre A-Z", "Nombre Z-A", "Menor precio", "Mayor precio"]
        let dropDown = DropDown()
        dropDown.anchorView = optionButton
        dropDown.dataSource = options
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            selectedPosition = index
            optionLabel.text = item
            self.viewModel.fetchingMore = false
            self.viewModel.page = 1
            self.fetchOffers(with: newTaxonomy, order: selectedPosition + 1)
        }
    }
}

extension OffersFilteredListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.productCollectionView {
            return viewModel.sections.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return viewModel.categories.count
        } else if collectionView == self.productCollectionView {
            if let products = viewModel.sections[section].product {
                return products.count
            }
            return viewModel.products.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionCollectionViewCell", for: indexPath) as! SectionCollectionViewCell
            
            header.indexPath = indexPath
            header.setSectionName(with: viewModel.sections[indexPath.section].name ?? "")
            
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == self.productCollectionView {
            if let products = viewModel.sections[section].product, !products.isEmpty {
                return CGSize(width: collectionView.bounds.width, height: 55)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 0)
            }
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesFilteredListCell", for: indexPath) as! CategoriesFilteredListCollectionViewCell
            let item = viewModel.categories[indexPath.row]
            cell.titleLabel.text = item.nombre
            
            if item.selected == true {
                cell.titleLabel.textColor = .white
                cell.cellView.backgroundColor = .primary
            } else {
                cell.titleLabel.textColor = .primary
                cell.cellView.backgroundColor = .yellow
            }
            
            return cell
        } else {
            return getProductCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func getProductCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.setProductData(with: viewModel.sections[indexPath.section].product?[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            let label = UILabel(frame: CGRect.zero)
            label.text = viewModel.categories[indexPath.row].nombre
            label.sizeToFit()
            return CGSize(width: (label.frame.width + 16), height: 40)
        } else {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            for i in 0..<viewModel.categories.count {
                viewModel.categories[i].selected = false
            }
            
            viewModel.categories[indexPath.row].selected = true
            self.collectionView.reloadData()
            
            self.viewModel.fetchingMore = false
            self.viewModel.page = 1
            self.selectedTaxonomy = viewModel.categories[indexPath.row].idTipoCategoriaApp ?? -1
            self.fetchOffers(with: viewModel.categories[indexPath.row].idTipoCategoriaApp ?? -1)
        } else if collectionView == self.productCollectionView {
            let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
            vc.offer = viewModel.sections[indexPath.section].product?[indexPath.row]
            vc.skuProduct = viewModel.sections[indexPath.section].product?[indexPath.row].productCode
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if !viewModel.fetchingMore {
                viewModel.fetchingMore = true
                viewModel.page += 1
                var newTaxonomy = taxonomy
                if selectedTaxonomy != -1 {
                    newTaxonomy = selectedTaxonomy
                }
                var order: Int?
                if selectedPosition != -1 {
                    order = selectedPosition + 1
                }
                self.fetchOffers(with: newTaxonomy, order: order)
            }
        }
    }
}

extension OffersFilteredListViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OffersFilteredListViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
