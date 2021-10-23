//
//  AccountsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct FilterRequest: APIRequest {

    public typealias Response = [FilterData]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<FilterServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct FilterServiceRequest: Codable {
    var idCompania: String
}
