//
//  CategoryCollectionViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 13/9/23.
//

import Nuke
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryIconView: UIView!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryArrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        content.layer.cornerRadius = 10
        categoryIconView.layer.cornerRadius = categoryIconView.frame.size.width / 2
        categoryIconImageView.layer.cornerRadius = categoryIconImageView.frame.size.width / 2
        
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.3
        self.contentView.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
        self.contentView.layer.shadowRadius = 3.0
    }
    
    // MARK: - Functions
    func configureCategory(with category: Categories?) {
        guard let category = category else { return }
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        if let url = URL(string: (category.imagen ?? "").replacingOccurrences(of: " ", with: "%20")) {
            Nuke.loadImage(with: url, options: options, into: categoryImageView)
        } else {
            categoryImageView.image = UIImage(named: "empty_image")
        }
        
        if let url = URL(string: (category.logo ?? "").replacingOccurrences(of: " ", with: "%20")) {
            Nuke.loadImage(with: url, options: options, into: categoryIconImageView)
        } else {
            categoryIconImageView.image = UIImage(named: "empty_image")
        }
        
        categoryNameLabel.text = category.descripcion
    }
}
