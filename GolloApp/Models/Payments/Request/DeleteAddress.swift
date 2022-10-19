//
//  DeleteAddress.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class DeleteAddress: Codable {
    init(idCliente: String, idDireccion: Int) {
        self.idCliente = idCliente
        self.idDireccion = idDireccion
    }
    
    var idCliente: String
    var idDireccion: Int
}
