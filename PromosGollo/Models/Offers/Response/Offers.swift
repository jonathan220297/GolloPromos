//
//  Offers.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

class Offers: Codable {
    var id: Int?
    var productCode: String?
    var name: String?
    var description: String?
    var brand: String?
    var modelo: String?
    var image: String?
    var originalPrice: Double?
    var porcDescuento: Double?
    var product: String?
    var productName: String?
    var montoBono: Double?
    var endDate: String?
    var startDate: String?
    var montoDescuento: Double?
    var precioFinal: Double?
    var tieneBono: String?
    var tieneRegalia: String?
    var tieneDescuento: String?
    var tipoPromoApp: String?
    var simboloMoneda: String?
}
