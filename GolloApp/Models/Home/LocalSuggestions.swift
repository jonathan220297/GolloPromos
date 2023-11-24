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
    
    init(id: String?, name: String?, image: String?) {
        self.id = id
        self.name = name
        self.image = image
    }
}
