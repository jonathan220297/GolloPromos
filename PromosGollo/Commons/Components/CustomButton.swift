//
//  CustomButton.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var translationKey: String?
    @IBInspectable var cornerRadiusValue: CGFloat = 10.0 {
        didSet {
            setUpView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }

    func setUpView() {
        self.layer.cornerRadius = self.cornerRadiusValue
        self.clipsToBounds = true
        if let key = self.translationKey {
            self.setTitle(key.localized, for: .normal)
        } else {
            assertionFailure("Translation not set for \(self.title(for: .normal) ?? "")")
        }
    }
}

