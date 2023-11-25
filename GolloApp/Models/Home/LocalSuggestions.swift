//
//  LocalSuggestions.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/11/23.
//

import Foundation

class LocalSuggestions {
    let id: String?
    let name, image: String?
    let isBrand: Bool
    let isHeader: Bool
    
    init(id: String?, name: String?, image: String?, isBrand: Bool, isHeader: Bool) {
        self.id = id
        self.name = name
        self.image = image
        self.isBrand = isBrand
        self.isHeader = isHeader
    }
}
