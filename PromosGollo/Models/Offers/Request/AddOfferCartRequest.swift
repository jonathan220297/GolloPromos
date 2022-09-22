//
//  AddOfferCartRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 20/9/22.
//

import Foundation

struct AddOfferCartRequest : APIRequest {

    public typealias Response = OfferCartDetail

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<AddOfferCartServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct AddOfferCartServiceRequest: Codable {
    var detalle: [CartItemDetail]?
    var idCliente: String
}

struct CartItemDetail: Codable {
    var cantidad, idLinea, mesesExtragar: Int
    var descripcion, sku: String
    var descuento, montoDescuento, montoExtragar, porcDescuento, precioExtendido, precioUnitario: Double
}

