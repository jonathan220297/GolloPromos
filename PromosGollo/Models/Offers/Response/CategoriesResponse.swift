//
//  CategoriesResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import Foundation

struct CategoriesData: Codable {
    let idTipoCategoriaApp: Int?
    let descripcion, urlImagen: String
    let cantidad, idTaxonomia: Int?
    let productos: [Product]
}
