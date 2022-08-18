//
//  StatusRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct StatusRequest: APIRequest {

    public typealias Response = StatusData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<StatusServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct StatusServiceRequest: Codable {
    var tipoId: String
    var idCliente: String
    var empresa: Int
    var idCentro: String? = nil
}
