//
//  SearchOffersRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 17/10/22.
//

import Foundation

struct SearchOffersRequest: APIRequest {

    public typealias Response = [Offers]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<SearchOffersServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct SearchOffersServiceRequest: Codable {
    var busqueda: String? = nil
    var idCliente, idCompania: String
    var idTaxonomia, numPagina, tamanoPagina: Int
}

