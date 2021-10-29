//
//  AccountsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct OffersRequest: APIRequest {

    public typealias Response = [Offers]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<OffersServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct OffersServiceRequest: Codable {
    var idCliente: String
    var idCompania: String
    var idCategoria: String? = nil
}
