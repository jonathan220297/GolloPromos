//
//  SaveUserAddressRequest.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class SaveUserAddressRequest: Codable {
    init(idCliente: String, idProvincia: String, idCanton: String, idDistrito: String? = nil, direccionExacta: String, codigoPostal: String, GPS_X: Double, GPS_Y: Double) {
        self.idCliente = idCliente
        self.idProvincia = idProvincia
        self.idCanton = idCanton
        self.idDistrito = idDistrito
        self.direccionExacta = direccionExacta
        self.codigoPostal = codigoPostal
        self.GPS_X = GPS_X
        self.GPS_Y = GPS_Y
    }
    
    var idCliente: String
    var idProvincia: String
    var idCanton: String
    var idDistrito: String?
    var direccionExacta: String
    var codigoPostal: String
    var GPS_X: Double
    var GPS_Y: Double
}
