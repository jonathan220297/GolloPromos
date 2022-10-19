//
//  UIImageView+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

extension UIImageView {
    func roundImage() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}
