//
//  OrderDetailRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation

struct OrderDetailRequest: APIRequest {
    public typealias Response = OrderDetailData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<OrderDetailServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct OrderDetailServiceRequest: Codable {
    var idCliente, idOrden: String
}
