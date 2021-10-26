//
//  AppTransaction.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/09/21.
//

import Foundation

struct AppTransaction: Codable {
    let idEmpresa: Int?
    let idMovimiento: Int?
    let integracionId: String?
    let procesada: Bool? // Indicador de si Gollo ha contestado  (no mostrar)
    let idTienda: String?
    let tipoIdCliente: String?
    let identificacionCliente: String?
    let nombreCliente: String?
    let mensajeEnvio: String?   // No mostrar
    let tipoMovimiento: String?  // C - Pago de cuota
    let emailCliente: String?
    let monto: Double?
    let tipoDocAplicado: String?    // FC - Factura de contado
    let numeroDocAplicado: String?  // # Factura
    let indAnulado, numCuenta, fecha: String?
}
