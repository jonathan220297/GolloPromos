//
//  Account.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

class Account: Codable {
    var idCuenta: String?
    var tipoCuenta: String?
    var empresa: String?
    var idTienda: String?
    var numCuenta: String?
    var fecha: String?
    var montoInicial: Double?
    var saldoActual: Double?
    var fechaUltimoPago: String?
    var fechaVencimiento: String?
    var fechaPago: String?
    var montoPago: Double?
    var montoMora: Double?
    var aplicaKiosco: String?
    var montoCancelarCuenta: Double?
}
