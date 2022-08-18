//
//  BaseRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import Foundation

struct BaseRequest<T: Codable, U: Codable>: APIRequest {

    public typealias Response = T

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<U>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}
