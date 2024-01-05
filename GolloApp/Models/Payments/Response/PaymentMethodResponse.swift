//
//  PaymentMethodResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 15/10/22.
//

import Foundation

class PaymentMethodResponse: Codable {
    let idFormaPago, formaPago, descripcion: String?
    let indTarjeta, indPrincipal, indTasaCero, indEmma: Int?
    let plazos: [ZeroRate]?
    let montoDisponibleEmma: Double?
    let linkDescarga: String?
    let indCrediGollo: Int?
    var selected: Bool? = false
}

class ZeroRate: Codable {
    let idPlazo, descPlazo: String?
}
