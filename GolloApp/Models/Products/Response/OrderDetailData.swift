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
    let idOrden, idMovimiento, totalLineas: Int?
    let idEmpresa, idCliente, estadoOrden, fechaOrden, condicionVenta, codigoCupon, descripcionCupon, numOrdenTienda: String?
    let montoProductos, montoEnvio, montoExtragarantia, montoBruto, montoDescuento: Double?
    let montoBono, montoNeto: Double?
}

struct PaymentType: Codable {
    let idFormaPago, codigoCupon, upcRelacionado, tipoTarjeta: String?
    let numeroTarjeta, codigoAutorizacion, fechaExpiraTarjeta, nombreTarjeta, descripcionFP: String?
    let montoTotal: Double?
    let noLineaProductoRelacionado, totalCuotas, principalFP: Int?
}

struct DeliveryType: Codable {
    let tipoEntrega, lugarDespacho, horaEntrega, fechaEntrega, instruccionesEspeciales: String?
    let direccion, tipoDireccion, idProvincia, provinciaDesc, idCanton, cantonDesc, idDistrito, distritoDesc: String?
    let tipoIdReceptor, idReceptor, parentescoReceptor, codigoPostal, receptorProducto, telefonoReceptor: String?
}

struct OrderDetailInformation: Codable {
    let porcDescuento, montoDescuento, precioUnitario, descuento: Double?
    let montoExtragar, mesesExtragar, precioExtendido: Double?
    let urlImagen, codRegalia, sku, descripcion: String?
    let cantidad, idLinea, esRegalia: Int?
}
