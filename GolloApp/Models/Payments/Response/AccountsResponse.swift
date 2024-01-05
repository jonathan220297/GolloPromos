//
//  AccountsResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/9/21.
//

import Foundation

// MARK: - Respuesta
struct ResponseAccont: Codable {
    let cuentas: [AccountsDetail]?
}

// MARK: - Cuenta
struct AccountsDetail: Codable {
    let idCuenta, tipoCuenta, empresa, idTienda, nombreTienda: String?
    let numCuenta, fecha: String?
    let montoInicial, saldoActual: Double?
    let fechaPago: String?
    let montoCancelarCuenta, montoAtraso: Double?
    let diasAtraso, montoAsistencia, totalCuotas, noCuota: Int?
    let montoCuota: Double?
    let montoMaximoPago, montoSugeridoBotonera, montoExtragarantia: Double?
    let descripcion, indicadorIncobrable, indicadorTasaCero: String?
}

