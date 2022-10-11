//
//  OrdersData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation

// MARK: - Respuesta
struct OrdersData: Codable {
    let ordenes: [Order]
}

struct Order: Codable {
    let idOrden, idMovimiento: Int?
    let idEmpresa, idCliente, condicionVenta, estadoOrden, ordenNaf: String?
    let fechaInclusion, fechaOrden, fechaBitacora: String?
    let usuarioInclusion, usuarioBitacora, descripcionCupon, codigoCupon: String?
}
