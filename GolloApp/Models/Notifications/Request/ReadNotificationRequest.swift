//
//  ReadNotificationRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 29/10/22.
//

import Foundation

struct ReadNotificationRequest: APIRequest {

    public typealias Response = NotificationsData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<ReadNotificationServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct ReadNotificationServiceRequest: Codable {
    var idCliente: String
    var idNotificacion: String
}

