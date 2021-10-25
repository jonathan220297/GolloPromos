//
//  BaseRequest.swift
//  PromosGollo
//
//  Created by Jonathan  Rodriguez on 21/10/21.
//

import Foundation

struct BaseRequest<T: Codable>: APIRequest {

    public typealias Response = T

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<LoginRequest>?
    
    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}
