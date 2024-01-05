//
//  VariationView.swift
//  Shoppi
//
//  Created by Jonathan  Rodriguez on 11/7/21.
//

import UIKit

protocol VariationDelegate {
    func variationView(_ variationView: VariationView, shouldReloadProductInfoFor variationId: String)
}

class VariationView: UIView {
    @IBOutlet weak var variationNameLabel: UILabel!
    @IBOutlet weak var variationsStackView: UIStackView!
    
    var attributes: [AttributeAux] = []
    var delegate: VariationDelegate?
    
    class func instanceFromNib() -> VariationView {
        return UINib(nibName: "VariationView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! VariationView
    }
    
    // MARK: - Observers
    @objc func buttonTapped(_ sender: UIButton) {
        let tag = sender.tag
        variationsStackView.subviews.forEach { view in
            let button = view as! UIButton
            button.setImage(nil, for: .normal)
        }
        for i in 0..<attributes.count {
            if i == tag {
                let button = variationsStackView.subviews[i] as! UIButton
                button.setImage(UIImage(named: "ic_check"), for: .normal)
            }
        }
        delegate?.variationView(self, shouldReloadProductInfoFor: attributes[tag].variationID ?? "")
    }
    
    // MARK: - Functions
    func setVariationData(with section: ProductAttribute) {
        attributes = section.attribute
        variationsStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        variationNameLabel.text = section.name ?? ""
        var i = 0
        for attribute in section.attribute {
            let button = UIButton()
            button.backgroundColor = hexStringToUIColor(hex: attribute.value ?? "")
            button.tintColor = .white
            if i == 0 {
                button.setImage(UIImage(named: "ic_check"), for: .normal)
            }
            button.widthAnchor.constraint(equalToConstant: 35).isActive = true
            variationsStackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.tag = i
            i += 1
        }
    }
}
