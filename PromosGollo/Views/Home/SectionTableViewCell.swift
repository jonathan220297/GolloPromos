//
//  SectionTableViewCell.swift
//  Shoppi
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift

protocol SectionDelegate {
    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, shouldReloadWith cellSize: Double)
    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, shouldReloadProductCellWith cellSize: Double)
    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, moveTo viewController: UIViewController)
}

class SectionTableViewCell: UITableViewCell {
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    lazy var viewModel: SectionViewModel = {
        return SectionViewModel()
    }()
    var delegate: SectionDelegate?
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    @IBAction func viewMoreButtonTapped(_ sender: UIButton) {
//        let tag = sender.tag
//        let vc = ProductsViewController.instantiate(fromAppStoryboard: .Products)
//        vc.modalPresentationStyle = .fullScreen
//        if tag == 0 {
//            vc.viewModel.provenance = .recents
//            delegate?.sectionTableView(self, moveTo: vc)
//        } else {
//            vc.viewModel.id = viewModel.section?.category ?? 0
//            vc.viewModel.provenance = .categories
//            delegate?.sectionTableView(self, moveTo: vc)
//        }
    }
    
    // MARK: - Functions
    func configureViewModel() {
        viewModel.reloadCollectionView = {[weak self] in
            guard let self = self else { return }
            self.productCollectionView.reloadData()
            let content = self.viewModel.productsArray.count
            let columns = Double(content) / 2.0
            let cellSize = round(columns) * 300.0
            self.delegate?.sectionTableView(self, shouldReloadWith: cellSize)
        }
    }
    
    func setSectionData(with section: Section, delegate: SectionDelegate) {
        self.delegate = delegate
        configureCollectionView()
        configureViewModel()
        sectionTitleLabel.text = section.name ?? ""
        viewModel.section = section
        guard let linkType = viewModel.section?.linkType else { return }
        switch linkType {
        case LinkType.none.rawValue:
            viewModel.configureRecentView()
            viewMoreButton.tag = 0
        case LinkType.appCategory.rawValue:
            fetchProducts(by: section.linkValue ?? "")
            viewMoreButton.tag = 1
            break
        default:
            break
        }
    }
    
    func configureCollectionView() {
        productCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        productCollectionView.collectionViewLayout = layout
        productCollectionView.isScrollEnabled = false
    }
    
    func fetchProducts(by category: String) {
        viewModel
            .fetchProductsByCategory(with: category)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.productsArray = data
                self.productCollectionView.reloadData()
                let content = self.viewModel.productsArray.count
                let columns = Double(content) / 2.0
                let cellSize = round(columns) * 350.0
                self.delegate?.sectionTableView(self, shouldReloadProductCellWith: cellSize)
            })
            .disposed(by: bag)
    }
}

extension SectionTableViewCell: UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getProductCell(collectionView, cellForItemAt: indexPath)
    }
    
    func getProductCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.setProductData(with: viewModel.productsArray[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SectionTableViewCell: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: ProductsData) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        self.delegate?.sectionTableView(self, moveTo: vc)
    }
}
