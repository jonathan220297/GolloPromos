//
//  AddressListRequest.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class AddressListRequest: Codable {
    init(idCliente: String) {
        self.idCliente = idCliente
    }
    
    var idCliente: String
}
