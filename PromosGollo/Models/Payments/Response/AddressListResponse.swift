//
//  AddressListResponse.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class AddressListResponse: Codable {
    init(direcciones: [UserAddress]) {
        self.direcciones = direcciones
    }
    
    var direcciones: [UserAddress]
}

class UserAddress: Codable {
    init(direccionExacta: String, gpsX: Int, idProvincia: String, provinciaDesc: String, codigoPostal: String? = nil, idEmpresa: Int, cantonDesc: String, distritoDesc: String, idDireccion: Int, estado: Bool, idCanton: String, idCliente: String, idDistrito: String, gpsY: Int) {
        self.direccionExacta = direccionExacta
        self.gpsX = gpsX
        self.idProvincia = idProvincia
        self.provinciaDesc = provinciaDesc
        self.codigoPostal = codigoPostal
        self.idEmpresa = idEmpresa
        self.cantonDesc = cantonDesc
        self.distritoDesc = distritoDesc
        self.idDireccion = idDireccion
        self.estado = estado
        self.idCanton = idCanton
        self.idCliente = idCliente
        self.idDistrito = idDistrito
        self.gpsY = gpsY
    }
    
    let direccionExacta: String
    let gpsX: Int
    let idProvincia, provinciaDesc: String
    let codigoPostal: String?
    let idEmpresa: Int
    let cantonDesc, distritoDesc: String
    let idDireccion: Int
    let estado: Bool
    let idCanton, idCliente, idDistrito: String
    let gpsY: Int
    
    enum CodingKeys: String, CodingKey {
        case direccionExacta
        case gpsX = "GPS_X"
        case idProvincia, codigoPostal, provinciaDesc, idEmpresa, cantonDesc, distritoDesc, idDireccion, estado, idCanton, idCliente, idDistrito
        case gpsY = "GPS_Y"
    }
}
