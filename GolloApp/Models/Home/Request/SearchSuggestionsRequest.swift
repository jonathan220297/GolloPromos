//
//  SearchSuggestionsRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/11/23.
//

import Foundation

struct SearchSuggestionsRequest: APIRequest {

    public typealias Response = SearchSuggestionsResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<SearchSuggestionsServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct SearchSuggestionsServiceRequest: Codable {
    var stringBusqueda: String?
    var idEmpresa: String = "10"
}
