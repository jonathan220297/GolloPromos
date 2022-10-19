//
//  OfferDetailRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 21/9/22.
//

import Foundation

struct OfferDetailRequest: APIRequest {

    public typealias Response = OfferDetail

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<OfferDetailServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct OfferDetailServiceRequest: Codable {
    var centro, sku: String
}
