//
//  ProductFooterCollectionViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 2/8/23.
//

import UIKit

protocol ProductFooterDelegate: AnyObject {
    func seeMoreTapped(indexPath: IndexPath)
}

class ProductFooterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var seeMoreButton: UIButton!
    var delegate: ProductFooterDelegate?
    var indexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Actions
    @IBAction func seeMoreButtonTapped(_ sender: UIButton) {
        delegate?.seeMoreTapped(indexPath: indexPath)
    }
}
