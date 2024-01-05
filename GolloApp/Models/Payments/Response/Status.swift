//
//  Status.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/09/21.
//

import Foundation

class Status: Codable {
    var datosCredito: CreditInfo?
    var cuentas: [Account] = []
    var totales: [Totals] = []
}

struct CreditInfo: Codable {
    var cmmActual: Double?
    var lemActual: Double?
    var cmmDisponible: Double?
    var lemDisponible: Double?
}

struct Totals: Codable {
    var totalMontoInicial: Double?
    var totalSaldoActual: Double?
    var totalMontoPago: Double?
    var totalMontoMora: Double?
}
