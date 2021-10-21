//
//  LoginRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

struct LoginRequest: APIRequest {

    public typealias Response = [LoginData]

    public var resourceName: String {
        return "Procesos"
    }

    public let clientId: String
    public let firstName: String
    public let lastName: String
    public let secondLastName: String
    public let loginType: String

    public var dictionary: [String: Any] {
        return [
            "servicio":[
                "encabezado": [
                    "idProceso": GOLLOAPP.LOGIN_PROCESS_ID,
                    "idDevice": "",
                    "idUsuario": UserManager.shared.userData?.uid ?? "",
                    "timeStamp": Date().timeIntervalSince1970,
                    "idCia": 10,
                    "token": ""
                ],
                "parametros": [
                    "idCliente": clientId,
                    "nombre": firstName,
                    "apellido1": lastName,
                    "apellido2": secondLastName,
                    "tipoLogin": loginType
                ]
            ]
        ]
    }
}
