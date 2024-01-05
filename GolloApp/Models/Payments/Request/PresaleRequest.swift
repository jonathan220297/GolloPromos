//
//  File.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 16/11/23.
//

import Foundation

struct PresaleRequest: APIRequest {

    public typealias Response = PresaleResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<PresaleServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct PresaleServiceRequest: Codable {
    var centro: String = "10"
    var numIdentificacion, tipoIdentificacion: String
    var monto, montoCSR, montoBono, montoFlete, montoDescuento, prima: Double
    var articulos: [CreditItem]
}
