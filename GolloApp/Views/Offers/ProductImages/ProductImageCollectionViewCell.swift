//
//  ProductImageCollectionViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/7/23.
//

import UIKit
import Nuke

class ProductImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Functions
    func setImageData(with data: ArticleImages?) {
        if let data = data {
            let options = ImageLoadingOptions(
                placeholder: UIImage(named: "empty_image"),
                transition: .fadeIn(duration: 0.5),
                failureImage: UIImage(named: "empty_image")
            )

            let url = URL(string: data.imagen ?? "")
            if let url = url {
                Nuke.loadImage(with: url, options: options, into: productImageView)
            } else {
                productImageView.image = UIImage(named: "empty_image")
            }
        } else {
            productImageView.image = UIImage(named: "empty_image")
        }
    }
    
}
