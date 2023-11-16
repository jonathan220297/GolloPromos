//
//  PresaleResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 16/11/23.
//

import Foundation

// MARK: - Respuesta
struct PresaleResponse: Codable {
    let numOperacion: String?
    let requiereAsistencia: Int?
    let montoAsistencia: Double?
    let plazos: [CrediGolloTerm]?
}

struct CrediGolloTerm: Codable {
    let cantidadMeses: Int
    let montoBase, montoIntereses, tasaAnual: Double
    let tasaEfectiva, montoTotal, montoMensual: Double
}
