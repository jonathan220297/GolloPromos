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
}

// MARK: - PaymentMethod
struct PaymentMethod: Codable {
    let codAutorizacion, fechaExp, idFormaPago: String
    let montoPago: Double
    let noLineaRelacionada: Int
    let nomTarjeta, numTarjeta, tipoPlazoTarjeta, tipoTarjeta: String
    let totalCuotas: Int
}

// MARK: - DeliveryInfo
struct DeliveryInfo: Codable {
    var codigoFlete: String
    var coordenadaX, coordenadaY: Double
    var direccion, email, fechaEntrega, firstName: String
    var horaEntrega, idCanton, idDistrito, idProvincia: String
    var idReceptor, lastName, lugarDespacho: String
    var montoFlete: Int
    var nomReceptor, postalCode, telReceptor, tipoEntrega: String
    var tipoIDRecep: String

    enum CodingKeys: String, CodingKey {
        case codigoFlete, coordenadaX, coordenadaY, direccion, email, fechaEntrega, firstName, horaEntrega, idCanton, idDistrito, idProvincia, idReceptor, lastName, lugarDespacho, montoFlete, nomReceptor, postalCode, telReceptor, tipoEntrega
        case tipoIDRecep = "tipoIdRecep"
    }
}
