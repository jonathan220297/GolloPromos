//
//  SearchSuggestionsResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/11/23.
//

import Foundation

// MARK: - HomeConfiguration
struct SearchSuggestionsResponse: Codable {
    let articulos: [SugggestionArticles]?
    let marcas: [SuggestionBrands]?
}

struct SugggestionArticles: Codable {
    let idArticulo, nombre, urlImagen: String?
}

struct SuggestionBrands: Codable {
    let marca: String?
}
