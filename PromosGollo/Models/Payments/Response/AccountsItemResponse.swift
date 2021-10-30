//
//  AccountsItemResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct AccountsItemResponse: Codable {
    let empresa, idPreventa: String?
    let articulos: [Items]?
}

struct Items: Codable {
    let codigoArticulo, descripcion: String?
    let cantidad: Int?
    let precioUnitario, precioBruto, descuentoval, impuestos: Double?
    let bodega, serie: String?
    let garantia: Int?
    let modelo, articuloRegalia, desArticuloRegalia: String?
    let cantRegalia: Int?
}
