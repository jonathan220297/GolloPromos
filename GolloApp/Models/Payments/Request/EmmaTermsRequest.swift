//
//  EmmaTermsRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 6/3/23.
//

import Foundation

struct EmmaTermsRequest: APIRequest {
    
    public typealias Response = EmmaTermsResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<EmmaTermsServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct EmmaTermsServiceRequest: Codable {
    var monto: Double
    var numIdentificacion: String
}
