//
//  StatusRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct SearchDocumentRequest: APIRequest {

    public typealias Response = ThirdPartyData

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<SearchDocumentServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct SearchDocumentServiceRequest: Codable {
    var noCia: String
    var numeroIdentificacion: String
    var tipoIdentificacion: String
}
