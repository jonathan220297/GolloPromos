//
//  OfferFilteredListRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/10/22.
//

import Foundation

struct OfferFilteredListRequest: APIRequest {

    public typealias Response = [Offers]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<OfferFilteredListServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct OfferFilteredListServiceRequest: Codable {
    var idCategoria: String? = nil
    var orden: Int? = nil
    var idCliente, idCompania: String
    var idTaxonomia, numPagina, tamanoPagina: Int
}
