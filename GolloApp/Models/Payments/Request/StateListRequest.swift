//
//  StateListRequest.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class StateListRequest: Codable {
    init(idProvincia: String, idCanton: String) {
        self.idProvincia = idProvincia
        self.idCanton = idCanton
    }
    
    var idProvincia: String
    var idCanton: String
}
