//
//  TransactionHistoryRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/22.
//

import Foundation

struct TransactionHistoryRequest: APIRequest {
    public typealias Response = TransactionHistoryResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<TransactionHistoryServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct TransactionHistoryServiceRequest: Codable {
    var empresa: String? = nil
    var idCliente: String? = nil
    var idCuenta: String? = nil
    var idOrigen: String? = nil
    var numPagos: Int? = 0
    var tipoId: String? = nil
}

