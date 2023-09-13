//
//  TopCategoriesCollectionViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 13/9/23.
//

import UIKit

protocol TopCategoriesDelegate: AnyObject {
    func didTapCategory(with controller: OffersFilteredListViewController)
    func didTapSeeMore(with controller: CategoriesViewController)
}

class TopCategoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    var section: MasterSection?
    var delegate: TopCategoriesDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Functions
    func configureCollectionView() {
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        categoriesCollectionView.register(
            UINib(
                nibName: "CategoryCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "CategoryCollectionViewCell"
        )
        categoriesCollectionView.register(
            UINib(
                nibName: "ExtraCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "ExtraCollectionViewCell"
        )
        categoriesCollectionView.reloadData()
    }
}

extension TopCategoriesCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section?.categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (self.section?.categories?[indexPath.row].extra ?? false) ?
        getExtraCell(collectionView, cellForItemAt: indexPath) :
        getCategoriesCell(collectionView, cellForItemAt: indexPath)
    }
    
    func getCategoriesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        cell.configureCategory(with: self.section?.categories?[indexPath.row])
        return cell
    }
    
    func getExtraCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtraCollectionViewCell", for: indexPath) as? ExtraCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 270)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.section?.categories?[indexPath.row].extra ?? false {
            let categoriesViewController = CategoriesViewController(
                viewModel: CategoriesViewModel()
            )
            categoriesViewController.modalPresentationStyle = .fullScreen
            delegate?.didTapSeeMore(with: categoriesViewController)
        } else {
            let offersFilteredListViewController = OffersFilteredListViewController(
                viewModel: OffersFilteredListViewModel(),
                category: self.section?.categories?[indexPath.row].idCategoria ?? 0,
                taxonomy: -1
            )
            offersFilteredListViewController.modalPresentationStyle = .fullScreen
            delegate?.didTapCategory(with: offersFilteredListViewController)
        }
    }
}
