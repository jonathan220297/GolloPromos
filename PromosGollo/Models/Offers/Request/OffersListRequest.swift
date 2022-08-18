//
//  AccountsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation

struct OffersListRequest: APIRequest {

    public typealias Response = [Offers]

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<OffersListServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct OffersListServiceRequest: Codable {
    var idCliente: String
    var idCompania: String
    var idCategoria: String? = nil
    var idCategoriaNaf: String? = nil
    var idTienda: String? = nil
    var idPromocion: String? = nil
    var busqueda: String? = nil
    var numPagina: Int
    var tamanoPagina: Int
}
