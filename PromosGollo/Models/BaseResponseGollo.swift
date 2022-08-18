//
//  BaseResponseGollo.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import Foundation

// MARK: - BaseResponse
struct BaseResponseGollo<T: Decodable>: Decodable {
    let resultado: Resultado?
    let respuesta: T?
}

// MARK: - Resultado
struct Resultado: Decodable {
    let codBanco, codTransaccion, codConvenio, compania: String?
    let codigoRespuesta, estado, mensaje: String?
}
