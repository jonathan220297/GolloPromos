//
//  CategoriesFilteredListRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/10/22.
//

import Foundation

struct CategoriesFilteredListRequest: APIRequest {
    public typealias Response = [CategoriesFilterData]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<CategoriesFilteredListServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct CategoriesFilteredListServiceRequest: Codable {
    var idCategoria: String? = nil
    var idCompania: String
    var idTaxonomia: Int
}
