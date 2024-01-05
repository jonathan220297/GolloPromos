//
//  AccountsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct AccountsRequest: APIRequest {

    public typealias Response = ResponseAccont

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<AccountsServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct AccountsServiceRequest: Codable {
    var tipoId: String
    var idCliente: String
    var empresa: String
    var idCentro: String? = nil
}
