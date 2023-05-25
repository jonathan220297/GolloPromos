//
//  UserResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/8/22.
//

import Foundation

struct UserData: Codable {
    let tipoIdentificacion, tarjetasDeCredito, estadoCivil, numeroIdentificacion : String?
    let nombre, apellido1, apellido2: String?
    let idRegistroBit: Int64?
    let salario: Double?
    let direccion, fechaIngresoTrabajo, corporacion: String?
    let lugarTrabajo, direccionTrabajo, telefonoTrabajo: String?
    let nombreConyugue, casa, genero, correoElectronico1, correoElectronico2, telefono1, telefono2: String?
    let cantidadHijos: String?
    let fechaNacimiento, nacionalidad, carroPropio, ocupacion, image: String?
    let emailValidacion, pinValidacion: String?
}
