//
//  StatusResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import Foundation

struct StatusData: Codable {
    let datosCredito: CreditData?
    let cuentas: [AccountData]?
    let totales: [TotalsData]?
}

struct CreditData: Codable {
    let cmmActual: Double?
    let lemActual: Double?
    let cmmDisponible: Double?
    let lemDisponible: Double?
    let efectivoLimite: Double?
    let efectivoDisponible: Double?
}

struct AccountData: Codable {
    let idCuenta: String?
    let tipoCuenta: String?
    let empresa: String?
    let idTienda: String?
    let numCuenta: String?
    let fecha: String?
    let montoInicial: Double?
    let saldoActual: Double?
    let fechaUltimoPago: String?
    let fechaVencimiento: String?
    let fechaPago: String?
    let montoPago: Double?
    let montoMora: Double?
    let aplicaKiosco: String?
    let montoCancelarCuenta: Double?
    let diasAtraso: Int?
    let montoAtraso: Double?
    let montoSugeridoPago: Double?
}

struct TotalsData: Codable {
    var totalMontoInicial: Double?
    var totalSaldoActual: Double?
    var totalMontoPago: Double?
    var totalMontoMora: Double?
}

