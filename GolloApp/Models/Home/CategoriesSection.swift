//
//  CategoriesSection.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 19/9/23.
//

import Foundation

class CategoriesSection {
    init(
        name: String? = nil,
        product: [Product]? = nil
    ) {
        self.name = name
        self.product = product
    }
    
    var name: String?
    var product: [Product]?
}
