//
//  StatusRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct AccountItemsRequest: APIRequest {

    public typealias Response = AccountsItemResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<AccountItemsServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct AccountItemsServiceRequest: Codable {
    var empresa: String? = nil
    var idCuenta: String? = nil
    var tipoMovimiento: String? = nil
}
