//
//  BaseHeaderRequest.swift
//  PromosGollo
//
//  Created by Jonathan  Rodriguez on 9/10/21.
//

import Foundation

struct BaseServiceRequestParam<T: Codable>: Codable {
    let servicio: ServicioParam<T?>
}

struct BaseServiceRequest: Codable {
    let servicio: Servicio
}

// MARK: - Servicio
struct ServicioParam<T: Codable>: Codable {
    let encabezado: Encabezado?
    let parametros: T?
}

struct Servicio: Codable {
    let encabezado: Encabezado?
}

// MARK: - Encabezado
struct Encabezado: Codable {
    let idProceso: String?
    let idDevice: String?
    let idUsuario: String?
    let timeStamp: String?
    let idCia: Int?
    let token: String?
    let integrationId: String?
}
