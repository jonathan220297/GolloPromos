//
//  BaseResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation

// MARK: - BaseResponse
class BaseResponse<T: Decodable>: Decodable {
    var status: Bool?
    var message: String?
    var debugMessage: String?
    var mapID: String?
    var data: T?
}

// MARK: - BaseResponseGollo
struct BaseResponseGollo<T: Decodable>: Decodable {
    let resultado: Resultado?
    let respuesta: T?
}

// MARK: - BaseResponseGolloAlternative
struct BaseResponseGolloAlternative<T: Decodable>: Decodable {
    let resultado: ResultadoAlternative?
    let respuesta: T?
}

// MARK: - Resultado
struct Resultado: Decodable {
    let estado: String?
    let mensaje: String?
}

// MARK: - ResultadoAlternative
struct ResultadoAlternative: Decodable {
    let estado: Bool
    let mensaje: String?
}
