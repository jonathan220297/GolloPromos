//
//  PaymentResponseDetailRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 27/10/22.
//

import Foundation

struct PaymentResponseDetailRequest: APIRequest {

    public typealias Response = PaymentResponse

    public var resourceName: String {
        return "Transacciones"
    }

    let service: BaseServiceRequestParam<PaymentResponseDetailServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct PaymentResponseDetailServiceRequest: Codable {
    var idProceso: String = ""
}
