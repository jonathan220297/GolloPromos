//
//  LocalizableLabel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import UIKit

class LocalizableLabel: UILabel {
    @IBInspectable var translationKey: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        if let key = self.translationKey {
            self.text = key.localized
        } else {
            assertionFailure("Translation not set for \(self.text ?? "")")
        }
    }
}

