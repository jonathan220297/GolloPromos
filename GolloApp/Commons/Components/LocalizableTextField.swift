//
//  LocalizableTextField.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import UIKit

class LocalizableTextField: UITextField {
    @IBInspectable var translationKey: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        if let key = self.translationKey {
            self.placeholder = key.localized
        } else {
            assertionFailure("Translation not set for \(self.placeholder ?? "")")
        }
    }
}
