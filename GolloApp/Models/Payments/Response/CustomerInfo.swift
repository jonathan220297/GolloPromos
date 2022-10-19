//
//  CustomerInfo.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/9/21.
//

import Foundation

class CustomerInfo: Codable {
    var idCliente: String
    var nombre: String
    var apellido1: String
    var apellido2: String
    var correoElectronico1: String?
    var tipoIdentificacion: String
    var numIdentificacion: String
    var idClienteNaf: String?
    var telefono: String?
    var celular: String?
    var direccion: String?
    var latitud: Double?
    var longitud: Double?
    var image: String?
    var fechaNacimiento: String?
    var genero: String?
    var fechaIngresoTrabajo: String?
    var salario: Double?
    var lugarTrabajo: String?
    var direccionTrabajo: String?
    var telefonoTrabajo: String?
    var otrosIngresos: Double?
    var estadoCivil: String?
    var nombreConyugue: String?
    var cantidadHijosL: Int?
    var casa: String?
    var correoElectronico2: String?
    var telefono1: String?
    var telefono2: String?
    var nacionalidad: String?
    var tarjetasDeCredito: String?
    var carroPropio: String?
    var ocupacion: String?
    var tipoOperacion: Int?
}
