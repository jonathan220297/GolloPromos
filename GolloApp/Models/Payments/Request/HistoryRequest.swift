//
//  StatusRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct HistoryRequest: APIRequest {

    public typealias Response = [AppTransaction]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<HistoryServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct HistoryServiceRequest: Codable {
    var idMovimiento: String? = nil
    var fechaInicial: String? = nil
    var fechaFinal: String? = nil
    var identificacionCliente: String? = nil
}
