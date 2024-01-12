//
//  OrdersData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation

// MARK: - Respuesta
struct OrdersData: Codable {
    let ordenes: [Order]?
}

struct Order: Codable {
    let idOrden, condicionVenta, estadoOrden, ordenNaf: String?
    let fechaInclusion, origen, fechaOrden, idEmpresa: String?
    let usuarioInclusion, descripcionCupon, usuarioBitacora: String?
    let idMovimiento, fechaBitacora, idCliente: String?
    let codigoCupon: String?
    let idJob: String?
    let isPickingInStore: Int?
}
