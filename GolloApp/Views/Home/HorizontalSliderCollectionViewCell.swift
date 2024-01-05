//
//  HorizontalSliderCollectionViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 12/9/23.
//

import UIKit

protocol HorizontalSliderDelegate: AnyObject {
    func didTapProduct(with controller: OfferDetailViewController)
    func didTapSeeMore(with controller: OffersFilteredListViewController)
}

class HorizontalSliderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    var section: MasterSection?
    var delegate: HorizontalSliderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }
    
    // MARK: - Functions
    func configureCollectionView() {
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(
            UINib(
                nibName: "ProductCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "ProductCollectionViewCell"
        )
        productCollectionView.register(
            UINib(
                nibName: "ExtraCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "ExtraCollectionViewCell"
        )
        productCollectionView.reloadData()
    }
}

extension HorizontalSliderCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section?.product?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (self.section?.product?[indexPath.row].extra ?? false) ?
        getExtraCell(collectionView, cellForItemAt: indexPath) :
        getProductCell(collectionView, cellForItemAt: indexPath)
    }
    
    func getProductCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        cell.setProductData(with: section?.product?[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func getExtraCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtraCollectionViewCell", for: indexPath) as? ExtraCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if section?.product?[indexPath.row].extra ?? false {
            let offersFilteredListViewController = OffersFilteredListViewController(
                viewModel: OffersFilteredListViewModel(),
                category: section?.link,
                taxonomy: section?.tax ?? -1
            )
            offersFilteredListViewController.modalPresentationStyle = .fullScreen
            delegate?.didTapSeeMore(with: offersFilteredListViewController)
        }
    }
}

extension HorizontalSliderCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 270)
    }
}

extension HorizontalSliderCollectionViewCell: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        delegate?.didTapProduct(with: vc)
    }
}
