//
//  LoginData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/9/21.
//

import Foundation

public class LoginData: Codable {
    let idCliente: String?
    let estadoLogin: Bool?
    let estadoCliente: Bool?
    let estadoRegistro: Bool?
    let token: String?

    public init(idCliente: String?, estadoLogin: Bool?, estadoRegistro: Bool?, estadoCliente: Bool?, token: String?) {
        self.idCliente = idCliente
        self.estadoLogin = estadoLogin
        self.estadoRegistro = estadoRegistro
        self.estadoCliente = estadoCliente
        self.token = token
    }
}

// MARK: - Store
public class UserInfo: NSObject, Codable {
    let idCliente, nombre, apellido1, apellido2: String?
    let correoElectronico1, telefono, numIdentificacion, idClienteNaf: String?
    let tipoOperacion: Int?


    public init(idCliente: String?, nombre: String?, apellido1: String?, apellido2: String?, correoElectronico1: String?, telefono: String?, numIdentificacion: String?, idClienteNaf: String?, tipoOperacion: Int?) {
        self.idCliente = idCliente
        self.nombre = nombre
        self.apellido1 = apellido1
        self.apellido2 = apellido2
        self.correoElectronico1 = correoElectronico1
        self.telefono = telefono
        self.numIdentificacion = numIdentificacion
        self.idClienteNaf = idClienteNaf
        self.tipoOperacion = tipoOperacion
    }
}
