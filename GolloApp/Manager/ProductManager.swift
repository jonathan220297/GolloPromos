//
//  ProductManager.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/8/23.
//

import Foundation
import UIKit

class ProductManager {
    func getTopRibbons(with data: Product) -> [ProductRibbon] {
        var ribbons: [ProductRibbon] = []
        if data.tieneDescuento?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.DESCUENTO, priority: 1))
        }
        if data.tieneBono?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.PRECIO_ESPECIAL, priority: 2))
        }
        if data.tiene2x1?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.OFERTA_2X1, priority: 3))
        }
        if data.tieneRegalia?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.REGALIA, priority: 4))
        }
        if data.tieneExclusivo?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.EXCLUSIVO_APP, priority: 5))
        }
        if data.tieneTopVentas?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.TOP_VENTAS, priority: 6))
        }
        if data.tienetranspGratis?.bool == true {
            ribbons.append(ProductRibbon(ribbonType: RibbonType.ENVIO_GRATIS, priority: 7))
        }
        let sorderRibbons = ribbons.sorted(by: { $0.priority > $1.priority }).prefix(2)
        return Array(sorderRibbons)
    }
    
    func getRibbonName(ribbon: ProductRibbon?) -> String {
        if let ribbon = ribbon {
            switch(ribbon.ribbonType) {
            case RibbonType.REGALIA:
                return "Regalía"
            case RibbonType.OFERTA_2X1:
                return "2x1"
            case RibbonType.EXCLUSIVO_APP:
                return "Exclusivo App"
            case RibbonType.TOP_VENTAS:
                return "Top en ventas"
            case RibbonType.ENVIO_GRATIS:
                return "Envío gratis"
            default:
                return ""
            }
        } else {
            return ""
        }
    }
    
    func getRibbonColor(ribbon: ProductRibbon?) -> UIColor {
        if let ribbon = ribbon {
            switch(ribbon.ribbonType) {
            case RibbonType.DESCUENTO:
                return UIColor.discount
            case RibbonType.PRECIO_ESPECIAL:
                return UIColor.bonus
            default:
                return UIColor.primary
            }
        } else {
            return UIColor.primary
        }
    }
}
