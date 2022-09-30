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
    let idEmpresa, idOrden, idMovimiento: Int?
    let idCliente, estadoOrden, fechaOrden, condicionVenta, codigoCupon, descripcionCupon: String?
    let usuarioInclusion, fechaInclusion, usuarioBitacora, fechaBitacora, ordenNaf: String?
}
