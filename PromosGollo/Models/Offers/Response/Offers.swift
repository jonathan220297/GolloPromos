//
//  Offers.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

struct Offers: Codable {
    let idempresa: Int?
    let idUsuario, simboloMoneda: String?
    let tipoPromoApp, id: Int?
    let productCode, name, description: String?
    let descriptionDetailBono, descriptionDetailDescuento, descriptionDetailRegalia: String?
    let brand, modelo, image: String?
    let originalPrice, porcDescuento: Double?
    let product, productName: String?
    let montoBono: Double?
    let endDate, startDate: String?
    let montoDescuento, precioFinal: Double?
    let tieneBono, tieneRegalia, tieneDescuento: String?
}

struct CategoryOffers {
    let category: CategoriesData
    let offers: [Product]
    let height: Int
}
