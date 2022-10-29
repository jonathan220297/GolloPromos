//
//  UnreadNotificationRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 29/10/22.
//

import Foundation

struct UnreadNotificationRequest: APIRequest {

    public typealias Response = UnreadNotificationData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<UnreadNotificationServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct UnreadNotificationServiceRequest: Codable {
    var idCliente: String
}
