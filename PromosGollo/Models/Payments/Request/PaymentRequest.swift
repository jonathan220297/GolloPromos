//
//  PaymentRequest.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 29/8/22.
//

import Foundation

struct PaymentRequest: APIRequest {

    public typealias Response = PaymentResponse

    public var resourceName: String {
        return "Transacciones"
    }

    let service: BaseServiceRequestParam<PaymentServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

class PaymentServiceRequest: Codable {
    init(integrationId: String?, idTienda: String = Variables().GOLLO_COMPANY, tipoIdCliente: String, identificacionCliente: String, tipoMovimiento: String, tipoDocMovimiento: String, numeroMovimiento: String, terminalId: String, monto: Double, tipoPago: String, numeroTarjeta: String, tipoPlazoTarjeta: String, moneda: String, nombreTarjetaHabiente: String, codigoSeguridad: String, fechaVencimiento: String) {
        self.integrationId = integrationId
        self.idTienda = idTienda
        self.tipoIdCliente = tipoIdCliente
        self.identificacionCliente = identificacionCliente
        self.tipoMovimiento = tipoMovimiento
        self.tipoDocMovimiento = tipoDocMovimiento
        self.numeroMovimiento = numeroMovimiento
        self.terminalId = terminalId
        self.monto = monto
        self.tipoPago = tipoPago
        self.numeroTarjeta = numeroTarjeta
        self.tipoPlazoTarjeta = tipoPlazoTarjeta
        self.moneda = moneda
        self.nombreTarjetaHabiente = nombreTarjetaHabiente
        self.codigoSeguridad = codigoSeguridad
        self.fechaVencimiento = fechaVencimiento
    }
    
    var integrationId: String?
    var idTienda: String = Variables().GOLLO_COMPANY
    var tipoIdCliente: String  // "C", (solo si es pago para otro cliente)
    var identificacionCliente: String //"204240308",(solo si es pago para otro cliente)
    var tipoMovimiento: String // "C", (C:Cuota, P:Preventa, F:Factura,)
    var tipoDocMovimiento: String // “FC”, (tipo documento según NAF:FC/R$...)
    var numeroMovimiento: String // “34453645646”, (Notransa_mov NAF)
    var terminalId: String // eventual id del teléfono
    var monto: Double
    var tipoPago: String // ”TA” (TA:Tarjeta)
    var numeroTarjeta: String // viene completo solo se guardan últimos 4 dígitos
    var tipoPlazoTarjeta: String // "11723675", (Codificar plazos tasa cero igual que Gollo)
    var moneda: String // "CRC", (de momento solo colones)
    var nombreTarjetaHabiente: String // "Luis Rodriguez",
    var codigoSeguridad: String
    var fechaVencimiento: String //"05/2028"
}
