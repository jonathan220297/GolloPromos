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
    let tipoId, identificacion, nombreCliente: String?
}

struct Payments: Codable {
    let fecha, idTienda, fechaPago, idCuenta, tipoCuenta: String?
    let idRecibo, noCuotaAsistencia, noFisico, numCuenta, empresa, descripcion: String?
    let montoRecibo, diaPago, diasAtraso: Int?
    let monProntoPago, monPagoMora, monCuotaAsistencia, monPagoInteres, monPagoCapital: Double?
    let montTotImpuesto, montoCuota, montoMaximoPago, saldoActual, montoCancelarCuenta, montoSugeridoBotonera: Double?
    let montoInicial, montoAtraso: Double?
}
