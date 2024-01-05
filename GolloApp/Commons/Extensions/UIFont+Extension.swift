//
//  UIFont+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

extension UIFont {
    class func sansSerifBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SansSerifBldFLF", size: size) ?? self.boldSystemFont(ofSize: size)
    }
    class func sansSerifDemiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SansSerifFLF-Demibold", size: size) ?? self.systemFont(ofSize: size)
    }
}
