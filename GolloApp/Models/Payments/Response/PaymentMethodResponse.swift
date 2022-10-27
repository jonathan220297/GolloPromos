//
//  PaymentMethodResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 15/10/22.
//

import Foundation

class PaymentMethodResponse: Codable {
    let idFormaPago, formaPago, descripcion: String?
    let indTarjeta, indPrincipal, indTasaCero: Int?
    let plazos: [Deadlines]?
    var selected: Bool? = false
}

class Deadlines: Codable {
    let idPlazo, descPlazo: String?
}
