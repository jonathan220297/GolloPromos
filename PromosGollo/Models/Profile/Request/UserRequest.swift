//
//  UserRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/8/22.
//

import Foundation

struct UserRequest: APIRequest {

    public typealias Response = UserData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<CategoriesServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct UserServiceRequest: Codable {
    var noCia: String
    var numeroIdentificacion: String
    var tipoIdentificacion: String
}
