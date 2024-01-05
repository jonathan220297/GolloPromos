//
//  UserInfo.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/9/21.
//

import Foundation

class UserInfoData: Codable {
    var idCliente: String = ""
    var nombre: String = ""
    var apellido1: String = ""
    var apellido2: String?
    var tipoIdentificacion: String?
    var numeroIdentificacion: String?
    var telefono1: String?
    var telefono2: String?
    var direccion: String?
    var latitud: Double?
    var longitud: Double?
    var correoElectronico1: String?
    var image: String?
    var fechaNacimiento: Date?
    var genero: String?
}
