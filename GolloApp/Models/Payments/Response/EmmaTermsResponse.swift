//
//  EmmaTermsResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 6/3/23.
//

import Foundation

struct EmmaTermsResponse: Codable {
    let pinValidacionEmma, emailValidacion: String?
    let plazos: [EmmaTerms]
}

struct EmmaTerms: Codable {
    let cantidadMeses: Int?
    let montoBase, montoIntereses, tasaAnual: Double?
    let tasaEfectiva, montoTotal, montoMensual: Double
    var selected: Bool? = false
}
