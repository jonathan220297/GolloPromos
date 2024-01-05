//
//  AccountDetail.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/9/21.
//

import Foundation

class AccountDetail: Codable {
    var idCuenta: String?
    var tipoCuenta: String?
    var empresa: String?
    var idTienda: String?
    var numCuenta: String?
    var fecha: String?
    var montoInicial: Double? = 0.0
    var saldoActual: Double? = 0.0
    var fechaPago: String?
    var montoCancelarCuenta: Double?
    var montoAtraso: Double? = 0.0
    var diasAtraso: Int? = 0
    var montoCuota: Double? = 0.0
    var montoMaximoPago: Double? = 0.0
    var dpp: Double? = 0.0
    var montoSugeridoBotonera: Double? = 0.0
    var diaPago: String?
    var descripcion: String?
}
