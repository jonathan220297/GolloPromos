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
    @IBOutlet weak var ribbonTopView: UIView!
    @IBOutlet weak var ribbonTopLabel: UILabel!
    @IBOutlet weak var ribbonBottomView: UIView!
    @IBOutlet weak var ribbonBottomLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    let bag = DisposeBag()
    var delegate: ProductCellDelegate?
    var dataG: Product?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
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
        
        let ribbons = ProductManager().getTopRibbons(with: data)
        // Hide Ribbons
        ribbonTopView.isHidden = true
        ribbonBottomView.isHidden = true
        
        if !ribbons.isEmpty {
            showTopRibbon(with: ProductManager().getRibbonName(ribbon: ribbons.first), ribbonColor: ProductManager().getRibbonColor(ribbon: ribbons.first))
            ribbonTopView.isHidden = false
            if ribbons.count == 2 {
                showBottomRibbon(with: ProductManager().getRibbonName(ribbon: ribbons[1]), ribbonColor: ProductManager().getRibbonColor(ribbon: ribbons[1]))
                ribbonBottomView.isHidden = false
            } else {
                ribbonBottomView.isHidden = true
            }
        } else {
            ribbonTopView.isHidden = true
        }
        
        if data.tieneDescuento?.bool ?? false {
            if data.muestraDescuento?.bool ?? false {
                if let discountPercentage = data.porcDescuento {
                    if discountPercentage == 0.0 {
                        productRealPriceLabel.text = ""
                        productRealPriceLabel.isHidden = true
                        //                        ribbonTopView.isHidden = true
                        //                        ribbonTopLabel.text = ""
                    } else {
                        let originalPrice = "₡\(numberFormatter.string(from: NSNumber(value: data.originalPrice ?? 0.0))!)"
                        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
                        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                     value: 2,
                                                     range: NSMakeRange(0, attributeString.length))
                        productRealPriceLabel.attributedText = attributeString
                        productRealPriceLabel.isHidden = false
                        //                        ribbonTopView.isHidden = false
                        //                        let discInt = Int(round(discountPercentage))
                        //                        ribbonTopLabel.text = String(discInt) + "%"
                        //                        ribbonTopView.clipsToBounds = true
                        //                        ribbonTopView.layer.cornerRadius = 10
                        //                        ribbonTopView.layer.maskedCorners = [.layerMaxXMaxYCorner]
                        //                        ribbonTopView.isHidden = false
                        //                        ribbonTopView.backgroundColor = UIColor.red
                    }
                } else {
                    productRealPriceLabel.text = ""
                    productRealPriceLabel.isHidden = true
                    //                    ribbonTopView.isHidden = true
                    //                    ribbonTopLabel.text = ""
                }
            } else {
                productRealPriceLabel.text = ""
                productRealPriceLabel.isHidden = true
                productDiscountPriceLabel.textColor = .black
                //                ribbonTopView.isHidden = true
                //                ribbonTopLabel.text = ""
            }
        } else if data.tieneRegalia?.bool ?? false {
            //            showGift(with: data)
            productRealPriceLabel.text = ""
            productRealPriceLabel.isHidden = true
        } else if data.tieneBono?.bool ?? false {
            //            showBono(with: data)
            let originalPrice = "₡\(numberFormatter.string(from: NSNumber(value: data.originalPrice ?? 0.0))!)"
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: 2,
                                         range: NSMakeRange(0, attributeString.length))
            productRealPriceLabel.attributedText = attributeString
            productRealPriceLabel.isHidden = false
        } else {
            productRealPriceLabel.text = ""
            productRealPriceLabel.isHidden = true
            //            ribbonTopView.isHidden = true
            //            ribbonTopLabel.text = ""
        }
    }
    
    func configureViews() {
        ribbonTopView.clipsToBounds = true
        ribbonTopView.layer.cornerRadius = 10
        ribbonTopView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        ribbonBottomView.clipsToBounds = true
        ribbonBottomView.layer.cornerRadius = 10
        ribbonBottomView.layer.maskedCorners = [.layerMinXMinYCorner]
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
        ribbonTopView.clipsToBounds = true
        ribbonTopView.layer.cornerRadius = 10
        ribbonTopView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        ribbonTopView.isHidden = false
        ribbonTopView.backgroundColor = UIColor.primary
        ribbonTopLabel.text = "Regalía"
        productRealPriceLabel.text = ""
        productRealPriceLabel.isHidden = true
    }
    
    func showBono(with data: Product) {
        ribbonTopView.clipsToBounds = true
        ribbonTopView.layer.cornerRadius = 10
        ribbonTopView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        ribbonTopView.backgroundColor = UIColor.bonus
        ribbonTopLabel.text = "Precio especial"
        ribbonTopLabel.font = ribbonTopLabel.font.withSize(12)
        let originalPrice = "₡\(numberFormatter.string(from: NSNumber(value: data.originalPrice ?? 0.0))!)"
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: originalPrice)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: 2,
                                     range: NSMakeRange(0, attributeString.length))
        productRealPriceLabel.attributedText = attributeString
        productRealPriceLabel.isHidden = false
        ribbonTopView.isHidden = false
        ribbonTopView.isHidden = false
    }
    
    private func showTopRibbon(with ribbonText: String, ribbonColor: UIColor) {
        ribbonTopLabel.text = ribbonText
        ribbonTopLabel.font = ribbonTopLabel.font.withSize(12)
        ribbonTopView.backgroundColor = ribbonColor
        ribbonTopView.isHidden = false
    }
    
    private func showBottomRibbon(with ribbonText: String, ribbonColor: UIColor) {
        ribbonBottomLabel.text = ribbonText
        ribbonBottomLabel.font = ribbonBottomLabel.font.withSize(12)
        ribbonBottomView.backgroundColor = ribbonColor
        ribbonBottomView.isHidden = false
    }
}

