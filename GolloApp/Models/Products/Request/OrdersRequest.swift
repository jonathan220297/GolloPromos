//
//  OrdersRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation

struct OrdersRequest: APIRequest {
    public typealias Response = OrdersData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<OrderServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct OrderServiceRequest: Codable {
    var idCliente: String
}
