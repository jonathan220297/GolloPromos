//
//  ProductCollectionViewCell.swift
//  Shoppi
//
//  Created by Jonathan  Rodriguez on 8/7/21.
//

import UIKit
import Nuke
import RxSwift

protocol ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product)
}

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var productDiscountPriceLabel: UILabel!
    @IBOutlet weak var productRealPriceLabel: UILabel!
    @IBOutlet weak var productDiscountPercentageLabel: UILabel!
    @IBOutlet weak var productDiscountPercentageView: UIView!
    @IBOutlet weak var detailButton: UIButton!
    
    let bag = DisposeBag()
    var delegate: ProductCellDelegate?
    var dataG: Product?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productDiscountPercentageView.clipsToBounds = true
        productDiscountPercentageView.layer.cornerRadius = 10
        productDiscountPercentageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        configureRx()
    }

    func setProductData(with data: Product?) {
        guard let data = data else { return }
        dataG = data

        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )

        if let url = URL(string: APDLGT.GIMGURL + (data.image ?? "")) {
            Nuke.loadImage(with: url, options: options, into: productImageView)
        }
        
        productNameLabel.text = data.brand ?? ""
        productTypeLabel.text = data.name ?? ""
        productDiscountPriceLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: data.precioFinal ?? 0.0))!)"

        let showDiscount = data.tieneDescuento?.bool ?? false || data.tieneBono?.bool ?? false

        if showDiscount {
            productDiscountPriceLabel.textColor = .red
        } else {
            productDiscountPriceLabel.textColor = .black
        }

        //if data.muestraDescuento?.bool ?? false {
            if data.tieneDescuento?.bool ?? false {
                if let discountPercentage = data.porcDescuento {
                    if discountPercentage == 0.0 {
                        productRealPriceLabel.text = ""
                        productRealPriceLabel.isHidden = true
                        productDiscountPercentageView.isHidden = true
                        productDiscountPercentageLabel.text = ""
                    } else {
                        let originalPrice = "₡\(numberFormatter.string(from: NSNumber(value: data.originalPrice ?? 0.0))!)"
                        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
                        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                     value: 2,
                                                     range: NSMakeRange(0, attributeString.length))
                        productRealPriceLabel.attributedText = attributeString
                        productRealPriceLabel.isHidden = false
                        productDiscountPercentageView.isHidden = false
                        let discInt = Int(round(discountPercentage))
                        productDiscountPercentageLabel.text = String(discInt) + "%"
                        productDiscountPercentageView.clipsToBounds = true
                        productDiscountPercentageView.layer.cornerRadius = 10
                        productDiscountPercentageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
                        productDiscountPercentageView.isHidden = false
                        productDiscountPercentageView.backgroundColor = UIColor.red
                    }
                } else {
                    productRealPriceLabel.text = ""
                    productRealPriceLabel.isHidden = true
                    productDiscountPercentageView.isHidden = true
                    productDiscountPercentageLabel.text = ""
                }
            } else if data.tieneRegalia?.bool ?? false {
                showGift(with: data)
            } else if data.tieneBono?.bool ?? false {
                showBono(with: data)
            } else {
                productRealPriceLabel.text = ""
                productRealPriceLabel.isHidden = true
                productDiscountPercentageView.isHidden = true
                productDiscountPercentageLabel.text = ""
            }
//        } else {
//            productRealPriceLabel.text = ""
//            productRealPriceLabel.isHidden = true
//            productDiscountPercentageView.isHidden = true
//            productDiscountPercentageLabel.text = ""
//        }

//        if data.tieneRegalia?.bool ?? false {
//            showGift(with: data)
//        } else if data.tieneBono?.bool ?? false {
//            showBono(with: data)
//        } else if data.tieneDescuento?.bool ?? false {
//            if let discountPercentage = data.porcDescuento {
//                if discountPercentage == 0.0 {
//                    productRealPriceLabel.text = ""
//                    productRealPriceLabel.isHidden = true
//                    productDiscountPercentageView.isHidden = true
//                    productDiscountPercentageLabel.text = ""
//                } else {
//                    let originalPrice = "₡\(numberFormatter.string(from: NSNumber(value: data.originalPrice ?? 0.0))!)"
//                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
//                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
//                                                 value: 2,
//                                                 range: NSMakeRange(0, attributeString.length))
//                    productRealPriceLabel.attributedText = attributeString
//                    productRealPriceLabel.isHidden = false
//                    productDiscountPercentageView.isHidden = false
//                    let discInt = Int(round(discountPercentage))
//                    productDiscountPercentageLabel.text = String(discInt) + "%"
//                    productDiscountPercentageView.clipsToBounds = true
//                    productDiscountPercentageView.layer.cornerRadius = 10
//                    productDiscountPercentageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
//                    productDiscountPercentageView.isHidden = false
//                    productDiscountPercentageView.backgroundColor = UIColor.red
//                }
//            } else {
//                productRealPriceLabel.text = ""
//                productRealPriceLabel.isHidden = true
//                productDiscountPercentageView.isHidden = true
//                productDiscountPercentageLabel.text = ""
//            }
//        } else {
//            productRealPriceLabel.text = ""
//            productRealPriceLabel.isHidden = true
//            productDiscountPercentageView.isHidden = true
//            productDiscountPercentageLabel.text = ""
//        }
    }
    
    func configureRx() {
        detailButton
            .rx
            .tap
            .subscribe(onNext: {
                guard let dataG = self.dataG else { return }
                self.delegate?.productCell(self, willMoveToDetilWith: dataG)
            })
            .disposed(by: bag)
    }

    func showGift(with data: Product) {
        productDiscountPercentageView.clipsToBounds = true
        productDiscountPercentageView.layer.cornerRadius = 10
        productDiscountPercentageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        productRealPriceLabel.text = ""
        productRealPriceLabel.isHidden = true
        productDiscountPercentageView.isHidden = false
        productDiscountPercentageView.backgroundColor = UIColor.primary
        productDiscountPercentageLabel.text = "Regalía"
    }

    func showBono(with data: Product) {
        productDiscountPercentageView.clipsToBounds = true
        productDiscountPercentageView.layer.cornerRadius = 10
        productDiscountPercentageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        productDiscountPercentageView.isHidden = false
        productDiscountPercentageView.backgroundColor = UIColor.bonus
        productDiscountPercentageLabel.text = "Bono"
        let originalPrice = "₡\(numberFormatter.string(from: NSNumber(value: data.originalPrice ?? 0.0))!)"
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: 2,
                                     range: NSMakeRange(0, attributeString.length))
        productRealPriceLabel.attributedText = attributeString
        productRealPriceLabel.isHidden = false
        productDiscountPercentageView.isHidden = false
    }
}

