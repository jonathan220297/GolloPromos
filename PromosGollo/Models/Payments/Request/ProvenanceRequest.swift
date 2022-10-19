//
//  ProvenanceRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/10/22.
//

import Foundation

struct ProvenanceRequest: APIRequest {

    public typealias Response = ProvenanceResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<ProvenanceServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct ProvenanceServiceRequest: Codable {
    var idCliente: String? = nil
}
