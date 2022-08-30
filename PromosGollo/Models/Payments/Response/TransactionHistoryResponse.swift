//
//  TransactionHistoryResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/22.
//

import Foundation

struct TransactionHistoryResponse: Codable {
    let informacionCuenta: AccountInfo?
    let pagos: [Payments]?
}

struct AccountInfo: Codable {
    let tipoId, idCliente, idCuenta: String
}

struct Payments: Codable {
    let fecha, idTienda: String?
    let idRecibo, noCuotaAsistencia, noFisico: String?
    let montoRecibo: Int?
    let monProntoPago, monPagoMora, monCuotaAsistencia, monPagoInteres, monPagoCapital: Double?
    let montTotImpuesto: Double?
}
