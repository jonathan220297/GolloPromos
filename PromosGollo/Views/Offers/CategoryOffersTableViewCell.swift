//
//  CategoryOffersTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan  Rodriguez on 27/10/21.
//

import UIKit
import Nuke
import RxSwift

protocol CategoryOffersDelegate {
    func categoryOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldMoveToDetailWith data: ProductsData)
    func categoryOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldReloadOffersForCategoryAt indexPath: IndexPath)
}

class CategoryOffersTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryOffersViewMoreButton: UIButton!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var offersCollectionView: UICollectionView!
    
    lazy var viewModel: CategoryOffersTableViewModel = {
        return CategoryOffersTableViewModel()
    }()
    var delegate: CategoryOffersDelegate?
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCollectionView() {
        offersCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        offersCollectionView.delegate = self
        offersCollectionView.dataSource = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        offersCollectionView.collectionViewLayout = layout
        offersCollectionView.reloadData()
    }
    
    func setCategoryInfo(with data: OfferSection) {
        if let url = URL(string: data.urlImage) {
            Nuke.loadImage(with: url, into: categoryImageView)
        }
        categoryNameLabel.text = data.name
    }
    
    func setViewsData() {
        if let url = URL(string: viewModel.category?.category.urlImagen ?? "") {
            Nuke.loadImage(with: url, into: categoryImageView)
        }
        categoryNameLabel.text = viewModel.category?.category.descripcion ?? ""
    }
    
    func configureRx() {
        categoryOffersViewMoreButton
            .rx
            .tap
            .subscribe(onNext: {
                self.delegate?.categoryOffers(self,
                                              shouldReloadOffersForCategoryAt: self.indexPath)
            })
            .disposed(by: bag)
    }
}

extension CategoryOffersTableViewCell: UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.category?.offers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getProductCell(collectionView, cellForItemAt: indexPath)
    }
    
    func getProductCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let offers = viewModel.category?.offers else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.setProductData(with: offers[indexPath.row])
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
        guard let data = viewModel.category?.offers[indexPath.row] else { return }
        delegate?.categoryOffers(self, shouldMoveToDetailWith: data)
    }
}

extension CategoryOffersTableViewCell: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: ProductsData) {
        delegate?.categoryOffers(self, shouldMoveToDetailWith: data)
    }
}
