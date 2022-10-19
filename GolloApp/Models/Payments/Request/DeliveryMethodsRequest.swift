//
//  DeliveryMethodsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 15/10/22.
//

import Foundation

struct DeliveryMethodsRequest: APIRequest {
    public typealias Response = DeliveryMethodsResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<DeliveryMethodsServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct DeliveryMethodsServiceRequest: Codable {
    var idCanton: String
    var idDistrito: String
    var idProvincia: String
}

