//
//  State.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class State: Codable {
    init(idProvincia: String, provincia: String) {
        self.idProvincia = idProvincia
        self.provincia = provincia
    }
    
    var idProvincia: String
    var provincia: String
}
