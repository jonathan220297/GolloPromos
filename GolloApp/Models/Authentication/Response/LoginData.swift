//
//  LoginData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/9/21.
//

import Foundation

struct LoginData: Codable {
    let idCliente: String?
    let estadoLogin: Bool?
    let estadoCliente: Bool?
    let estadoRegistro: Bool?
    let token: String?
    let registro: UserInfo?
}

// MARK: - RegisterInfo
struct RegisterInfo: Codable {
    let idCliente, nombre, apellido1, apellido2: String?
    let tipoIdentificacion, numeroIdentificacion, telefono, celular, direccion: String?
    let latitud, longitud: Double?
    let correoElectronico1, fechaNacimiento, genero, fechaIngresoTrabajo: String?
}

// MARK: - Store
public class UserInfo: NSObject, Codable {
    let idCliente, nombre, apellido1, apellido2: String?
    let telefono1, telefono2, tipoIdentificacion, numeroIdentificacion, direccion: String?
    let latitud, longitud: Double?
    let correoElectronico1, fechaNacimiento, image, genero: String?

    public init(idCliente: String?, nombre: String?, apellido1: String?, apellido2: String?, telefono1: String?, telefono2: String?, tipoIdentificacion: String?, numeroIdentificacion: String?, direccion: String?, latitud: Double?, longitud: Double?, correoElectronico1: String?, fechaNacimiento: String?, image: String?, genero: String?) {
        self.idCliente = idCliente
        self.nombre = nombre
        self.apellido1 = apellido1
        self.apellido2 = apellido2
        self.telefono1 = telefono1
        self.telefono2 = telefono2
        self.tipoIdentificacion = tipoIdentificacion
        self.numeroIdentificacion = numeroIdentificacion
        self.direccion = direccion
        self.latitud = latitud
        self.longitud = longitud
        self.correoElectronico1 = correoElectronico1
        self.fechaNacimiento = fechaNacimiento
        self.image = image
        self.genero = genero
    }
}
