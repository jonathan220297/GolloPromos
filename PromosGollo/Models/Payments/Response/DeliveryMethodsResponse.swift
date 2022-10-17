//
//  DeliveryMethodsResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 15/10/22.
//

import Foundation

struct DeliveryMethodsResponse: Codable {
    let idProvincia, idCanton, idDistrito: String?
    let fletes: [Freight]?
}

struct Freight: Codable {
    let codigoFlete, nombre, descripcion: String?
    let monto: Double?
}
