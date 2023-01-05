//
//  DeviceTokenRequets.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 18/11/22.
//

import Foundation

struct DeviceTokenRequest: APIRequest {

    public typealias Response = DeviceTokenResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<DeviceTokenServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct DeviceTokenServiceRequest: Codable {
    var deleteAction: String
    var idCliente: String? = nil
    var idDevice: String
    var idDeviceToken: String
    var idSistemaOperativo: String
}
