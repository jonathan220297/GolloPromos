//
//  UIColor+Assets.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

extension UIColor {
    static let terracotta = UIColor.fromAsset(named: "Terracotta")
    static let primary = UIColor.fromAsset(named: "colorPrimary")
    static let primaryLight = UIColor.fromAsset(named: "colorPrimaryLight")
}

fileprivate extension UIColor {
    static func fromAsset(named name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            fatalError("Color \(name) is not defined in a color asset.")
        }
        return color
    }
}

