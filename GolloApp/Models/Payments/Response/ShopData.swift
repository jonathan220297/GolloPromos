//
//  ShopData.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

// MARK: - ShopData
struct ShopData: Codable {
    let idTienda, nombre: String
    let direccion, telefono: String?
    let latitud, longitud: Double?
    let provincia: String?
    let canton: String
    let distrito: String?
}
