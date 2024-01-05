//
//  NotificationRequest.swift
//  Shoppi
//
//  Created by Rodrigo Osegueda on 26/7/21.
//

import Foundation

struct NotificationsRequest: APIRequest {

    public typealias Response = [NotificationsData]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<NotificationsServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct NotificationsServiceRequest: Codable {
    var idCliente, idCompania: String
    var numPagina, tamanoPagina: Int
}

