//
//  LoginRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

struct LoginRequest: Codable {
    public let idCliente: String
    public let nombre: String
    public let apellido1: String
    public let apellido2: String
    public let tipoLogin: String
}

enum LoginType: Int {
    case none = 0, email, google, facebook, phone, apple
}
