//
//  ThirdPartyResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import Foundation

// MARK: - Respuesta
struct ThirdPartyData: Codable {
    let tipoIdentificacion, tarjetasDeCredito, estadoCivil, nacionalidad: String?
    let apellido1, telefono2, direccionTrabajo, lugarTrabajo: String?
    let idRegistroBit, otrosIngresos: Int?
    let numeroIdentificacion, corporacion: String?
    let salario: Double?
    let telefonoTrabajo, casa, genero, nombre: String?
    let correoElectronico1, correoElectronico2, ocupacion, nombreConyugue: String?
    let cantidadHijos: Int?
    let apellido2, telefono1, carroPropio, fechaIngresoTrabajo: String?
    let fechaNacimiento: String?
}

