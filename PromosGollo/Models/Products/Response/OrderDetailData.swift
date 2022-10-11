//
//  OrderDetailData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation

struct OrderDetailData: Codable {
    let detalle: [OrderDetail]
}

struct OrderDetail: Codable {
    let orden: OrderInformation
    let formasPago: [PaymentType]
    let formaEntrega: [DeliveryType]
    let ordenDetalle: [OrderDetailInformation]
}

struct OrderInformation: Codable {
    let idEmpresa, idOrden, idMovimiento, totalLineas: Int?
    let idCliente, estadoOrden, fechaOrden, condicionVenta, codigoCupon, descripcionCupon, numOrdenTienda: String?
    let montoBruto, montoDescuento, montoExtragarantia: Double?
}

struct PaymentType: Codable {
    let idFormaPago, codigoCupon, upcRelacionado, tipoTarjeta: String?
    let numeroTarjeta, codigoAutorizacion, fechaExpiraTarjeta, nombreTarjeta: String?
    let montoTotal: Double?
    let noLineaProductoRelacionado, totalCuotas: Int?
}

struct DeliveryType: Codable {
    let tipoEntrega, lugarDespacho, horaEntrega, fechaEntrega, instruccionesEspeciales: String?
    let direccion, tipoDireccion, idProvincia, provinciaDesc, idCanton, cantonDesc, idDistrito, distritoDesc: String?
    let tipoIdReceptor, idReceptor, parentescoReceptor, codigoPostal, receptorProducto, telefonoReceptor: String?
}

struct OrderDetailInformation: Codable {
    let sku, descripcion, codRegalia, urlImagen: String?
    let idLinea, cantidad, mesesExtragar, esRegalia: Int?
    let precioUnitario, descuento, precioExtendido, montoExtragar, porcDescuento, montoDescuento: Double?
}
