//
//  ProductCollectionViewCell.swift
//  Shoppi
//
//  Created by Jonathan  Rodriguez on 8/7/21.
//

import UIKit
import Nuke

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDiscountPriceLabel: UILabel!
    @IBOutlet weak var productRealPriceLabel: UILabel!
    @IBOutlet weak var productInStockLabel: UILabel!
    @IBOutlet weak var productRatingStackView: UIStackView!
    @IBOutlet weak var productDiscountPercentageLabel: UILabel!
    @IBOutlet weak var productDiscountPercentageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentViewCell.layer.cornerRadius = 10
    }

    func setProductData(with data: ProductsData) {
        if let url = URL(string: APDLGT.GIMGURL + (data.mainImage ?? "")) {
            Nuke.loadImage(with: url, into: productImageView)
        }
        productNameLabel.text = data.name ?? ""
        productDiscountPriceLabel.text = (data.salePrice ?? "").currencyFormatting()
        if let discountPercentage = data.discountPercentage {
            if discountPercentage == "0" {
                productRealPriceLabel.text = ""
                productRealPriceLabel.isHidden = true
                productDiscountPercentageView.isHidden = true
                productDiscountPercentageLabel.text = ""
            } else {
                let originalPrice = (data.originalPrice ?? "").currencyFormatting()
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                             value: 2,
                                             range: NSMakeRange(0, attributeString.length))
                productRealPriceLabel.attributedText = attributeString
                productRealPriceLabel.isHidden = false
                productDiscountPercentageView.isHidden = false
                productDiscountPercentageLabel.text = discountPercentage + "%"
            }
        } else {
            productRealPriceLabel.text = ""
            productRealPriceLabel.isHidden = true
            productDiscountPercentageView.isHidden = true
            productDiscountPercentageLabel.text = ""
        }
        if let inStock = data.inStock {
            productInStockLabel.text = inStock ? "In stock" : "Sold out"
            productInStockLabel.textColor = inStock ? UIColor.cyan : UIColor.red
        } else {
            productInStockLabel.text = "In stock"
        }
        if let ratingCount = data.ratingCount {
            productRatingStackView.subviews.forEach { view in
                view.removeFromSuperview()
            }
            for i in 1...5 {
                if i > 0 && i <= ratingCount {
                    let image = UIImageView(image: UIImage(imageLiteralResourceName: "icon_star_on"))
                    image.contentMode = .scaleAspectFit
                    productRatingStackView.addArrangedSubview(image)
                } else {
                    let image = UIImageView(image: UIImage(imageLiteralResourceName: "icon_star_off"))
                    image.tintColor = .lightGray
                    image.contentMode = .scaleAspectFit
                    productRatingStackView.addArrangedSubview(image)
                }
            }
        }
    }
}
