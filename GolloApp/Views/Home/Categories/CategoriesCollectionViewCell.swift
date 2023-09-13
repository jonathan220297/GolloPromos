//
//  CategoriesCollectionViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 8/9/23.
//

import UIKit
import Nuke

class CategoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var content: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setCategoriesData(with data: CategoryFilteredList) {
        nameLabel.text = data.name
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        if let categoryImage = data.image, !categoryImage.isEmpty, categoryImage != "NA" {
            if let url = URL(string: (data.image ?? "")) {
                Nuke.loadImage(with: url, options: options, into: categoryImageView)
            } else {
                categoryImageView.image = UIImage(named: "empty_image")
            }
        } else {
            categoryImageView.image = UIImage(named: "empty_image")
        }
    }
    
}
