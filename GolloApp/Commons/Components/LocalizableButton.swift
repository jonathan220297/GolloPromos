//
//  LocalizableButton.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import UIKit

class LocalizableButton: UIButton {
    @IBInspectable var translationKey: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        if let key = self.translationKey {
            self.setTitle(key.localized, for: .normal)
        } else {
            assertionFailure("Translation not set for \(self.title(for: .normal) ?? "")")
        }
    }
}

