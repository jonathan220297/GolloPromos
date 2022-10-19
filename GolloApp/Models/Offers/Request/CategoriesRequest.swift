//
//  AccountsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct CategoriesRequest: APIRequest {

    public typealias Response = [CategoriesData]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<CategoriesServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct CategoriesServiceRequest: Codable {
    var idCliente: String
    var idCategoria: String? = nil
    var idCompania: String
}
