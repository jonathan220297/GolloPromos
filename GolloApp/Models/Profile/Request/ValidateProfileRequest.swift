//
//  ValidateUserInformationRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 18/8/23.
//

import Foundation

struct ValidateProfileRequest: APIRequest {

    public typealias Response = ValidateProfileResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<ValidateProfileServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct ValidateProfileServiceRequest: Codable {
    var noCia: String = "10"
    var numeroIdentificacion, tipoIdentificacion: String
}
