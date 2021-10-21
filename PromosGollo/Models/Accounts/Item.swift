//
//  Item.swift
//  asesorCajero
//
//  Created by Rodrigo Osegueda on 8/6/21.
//

import Foundation

class Item: Codable {
    var codigoArticulo: String?
    var descripcion: String?
    var cantidad: Int?
    var precioUnitario: Double?
    var precioBruto: Double?
    var descuentoval: Double?
    var impuestos: Double?
    var bodega: String?
    var serie: String?
    var garantia: Int?
    var modelo: String?
    var articuloRegalia: String?
    var desArticuloRegalia: String?
    var cantRegalia: Int?
}
