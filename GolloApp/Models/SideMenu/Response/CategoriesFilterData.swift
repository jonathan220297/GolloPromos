//
//  CategoriesData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import Foundation

struct CategoriesFilterData: Codable {
    let parent, totalHijos, idTipoCategoriaApp: Int?
    let nombre, descripcion: String?
    let image: String?
    var selected: Bool? = false
}
