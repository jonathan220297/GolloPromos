//
//  DeleteProfileRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 30/10/22.
//

import Foundation

struct DeleteProfileRequest: APIRequest {

    public typealias Response = LoginData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<DeleteProfileServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct DeleteProfileServiceRequest: Codable {
    var idEmpresa: Int
    var idCliente: String
}
