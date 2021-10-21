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
    
    public let enterprise: Int
    public let user: String
    public let notificationType: Int
    public let page: Int
    public let perPage: Int
    public let search: String
    public let notificationId: String
    
    public var dictionary: [String: Any] {
        return [
            "idEmpresa": enterprise,
            "usuario": user,
            "idTipoNotificacion": notificationType,
            "numPagina": page,
            "tamanoPagina": perPage,
            "busqueda": search,
            "idNotificacion": notificationId
        ]
    }
}
