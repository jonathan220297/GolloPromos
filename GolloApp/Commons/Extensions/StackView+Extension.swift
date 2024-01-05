//
//  StackView+Extension.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 11/8/23.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}
