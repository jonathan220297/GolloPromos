//
//  RegisterDeviceRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 30/10/22.
//

import Foundation

struct RegisterDeviceRequest: APIRequest {

    public typealias Response = LoginData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<RegisterDeviceServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct RegisterDeviceServiceRequest: Codable {
    var idEmpresa: Int
    var idDeviceToken: String
    var Token: String? = nil
    var idCliente: String? = nil
    var idDevice: String
}
