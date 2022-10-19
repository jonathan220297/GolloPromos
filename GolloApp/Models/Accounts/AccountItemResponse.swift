//
//  AccountItemResponse.swift
//  asesorCajero
//
//  Created by Rodrigo Osegueda on 8/6/21.
//

import Foundation

class AccountItemResponse: Codable {
    var empresa: String?
    var idPreventa: String?
    var articulos: [Item]?
}
