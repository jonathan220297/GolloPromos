//
//  SaveUserResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/8/22.
//

import Foundation

class SaveUserResponse: Codable {
    let idCliente: String?
    let estadoLogin, estadoCliente, estadoRegistro: Bool
}
