//
//  CategoriesRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import Foundation

struct CategoriesFilterRequest: APIRequest {
    public typealias Response = [CategoriesFilterData]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<CategoriesFilterServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct CategoriesFilterServiceRequest: Codable {
    var idCompania: String
}
