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
    let tipoId, idCuenta, idCliente: String?
}

struct Payments: Codable {
    let fecha, idTienda, noCuotaAsistencia, idRecibo, noFisico: String?
    let monProntoPago, monPagoMora, monCuotaAsistencia, montoRecibo: Double?
    let monPagoInteres, monPagoCapital, montTotImpuesto: Double?
}
