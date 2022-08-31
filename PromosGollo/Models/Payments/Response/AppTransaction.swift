//
//  AppTransaction.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/09/21.
//

import Foundation

struct AppTransaction: Codable {
    let idTienda, tipoMovimiento, emailCliente, numCuenta, fecha: String?
    let nombreCliente, numeroDocAplicado, integracionId, identificacionCliente: String?
    let procesada, tipoIdCliente, mensajeEnvio, tipoDocAplicado, indAnulado: String?
    let idEmpresa, idMovimiento: Int?
    let monto: Double?
}
