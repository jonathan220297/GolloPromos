//
//  LoginRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

struct LoginRequest: APIRequest {

    public typealias Response = LoginData

    public var resourceName: String {
        return "Procesos/Login"
    }

    let service: BaseServiceRequestParam<LoginServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct LoginServiceRequest: Codable {
    public let idCliente: String
    public let nombre: String
    public let apellido1: String
    public let apellido2: String
    public let tipoLogin: String
}

enum LoginType: Int {
    case none = 0, email, google, facebook, phone, apple
}
