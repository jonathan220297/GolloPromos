//
//  BaseResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation

// MARK: - BaseResponse
struct BaseResponse<T: Decodable>: Decodable {
    let resultado: Resultado?
    let respuesta: T?
}

// MARK: - Resultado
struct Resultado: Decodable {
    let estado: Bool?
    let mensaje: String?
}
