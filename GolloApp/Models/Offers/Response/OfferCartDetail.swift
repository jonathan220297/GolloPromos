//
//  OfferCartDetail.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 21/9/22.
//

import Foundation

struct OfferCartDetail: Codable {
    let idCliente, codigoCupon: String?
    let detalle: [OfferCartItemDetail]?
}

struct OfferCartItemDetail: Codable {
    let idLinea, cantidad, mesesExtragar: Int?
    let sku, descripcion, codRegalia: String?
    let precioUnitario, descuento, precioExtendido, montoExtragar, porcDescuento: Double?
}
