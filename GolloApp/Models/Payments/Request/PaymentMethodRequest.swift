//
//  PaymentMethodRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 15/10/22.
//

import Foundation

struct PaymentMethodRequets: APIRequest {
    public typealias Response = [PaymentMethodResponse]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<PaymentMethodServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct PaymentMethodServiceRequest: Codable {
    var idCliente: String? = nil
    var numIdentificacion: String
    var formaPago: Int
}
