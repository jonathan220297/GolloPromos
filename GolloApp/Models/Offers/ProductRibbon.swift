//
//  ProductRibbon.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/8/23.
//

import Foundation

class ProductRibbon {
    init(ribbonType: RibbonType, priority: Int) {
        self.ribbonType = ribbonType
        self.priority = priority
    }
    
    var ribbonType: RibbonType = RibbonType.NONE
    var priority: Int = 0
}

enum RibbonType {
    case NONE
    case DESCUENTO
    case PRECIO_ESPECIAL
    case OFERTA_2X1
    case REGALIA
    case EXCLUSIVO_APP
    case TOP_VENTAS
    case NUEVO
    case ENVIO_GRATIS
}
