//
//  ProductsRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

struct ProductsRequest: APIRequest {

    public typealias Response = [Product]
    
    public var resourceName: String {
        return "Procesos"
    }
    
    let service: BaseServiceRequestParam<ProductServiceRequest>?
    
    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}

struct ProductServiceRequest: Codable {
    var idCliente: String
    var idCompania: String
    var idCategoria: String? = nil  // Categoria App
    var idCategoriaNaf: String? = nil // Categoria Naf
    var idTienda: String? = nil
    var idPromocion: String? = nil
    var busqueda: String? = nil
    var numPagina: Int
    var tamanoPagina: Int
}
