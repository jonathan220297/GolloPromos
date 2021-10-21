//
//  AppTransaction.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/09/21.
//

import Foundation

class AppTransaction: Codable {
    var idEmpresa: Int
    var idMovimiento: Int
    var integracionId: String?
    var procesada: Bool // Indicador de si Gollo ha contestado  (no mostrar)
    var idTienda: String
    var tipoIdCliente: String
    var identificacionCliente: String
    var nombreCliente: String
    var mensajeEnvio: String?   // No mostrar
    var tipoMovimiento: String  // C - Pago de cuota
    var emailCliente: String
    var monto: Double
    var tipoDocAplicado: String?    // FC - Factura de contado
    var numeroDocAplicado: String?  // # Factura
    var indAnulado: String
    var numCuenta: String
    var fecha: String
}
