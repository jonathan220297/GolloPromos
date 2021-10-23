//
//  FilterResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import Foundation

struct FilterData: Codable {
    var idTienda, nombre, direccion, telefono: String?
    var latitud, longitud: Double?
    var provincia, canton, distrito: String?
}
