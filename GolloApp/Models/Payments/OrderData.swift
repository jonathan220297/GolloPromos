//
//  OrderData.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

// MARK: - OrderData
struct OrderData: Codable {
    let detalle: [OrderItem]
    let formaPago: [PaymentMethod]
    let idCliente: String
    let infoEntrega: DeliveryInfo
    let indScanAndGo: Bool
    let requiereInstaleap, indInstaleap: Int
}

// MARK: - OrderItem
struct OrderItem: Codable {
    let cantidad, mesesExtragar, idLinea: Int
    let descripcion: String
    let descuento: Int
    let montoDescuento, montoExtragar, porcDescuento: Double
    let precioExtendido, precioUnitario: Double
    let sku: String
    let tipoSku: Int
    let montoBonoProveedor: Double?
    let codRegalia: String?
    let descRegalia: String?
}

// MARK: - PaymentMethod
struct PaymentMethod: Codable {
    let codAutorizacion, fechaExp, idFormaPago: String
    let skuRelacionado: String?
    let montoPago: Double
    let noLineaRelacionada: Int
    let nomTarjeta, numTarjeta, tipoPlazoTarjeta, tipoTarjeta: String
    let totalCuotas: Int
    let indTarjeta, indPrincipal, indEmma: Int
    let pinValidacionEmma, plazoCredito: Int?
    let prima: Double?
}

// MARK: - DeliveryInfo
struct DeliveryInfo: Codable {
    var codigoFlete: String
    var coordenadaX, coordenadaY: Double
    var direccion, email, fechaEntrega, firstName: String
    var horaEntrega, idCanton, idDistrito, idProvincia: String
    var idReceptor, lastName, lugarDespacho: String
    var montoFlete: Double
    var nomReceptor, telReceptor, tipoEntrega: String
    var postalCode: String? = nil
    var tipoIDRecep: String
    var idJob: String? = nil
    var idSlot: String? = nil

    enum CodingKeys: String, CodingKey {
        case codigoFlete, coordenadaX, coordenadaY, direccion, email, fechaEntrega, firstName, horaEntrega, idCanton, idDistrito, idProvincia, idReceptor, lastName, lugarDespacho, montoFlete, nomReceptor, postalCode, telReceptor, tipoEntrega, idJob, idSlot
        case tipoIDRecep = "tipoIdRecep"
    }
}
