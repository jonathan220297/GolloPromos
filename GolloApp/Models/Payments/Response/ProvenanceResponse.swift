//
//  ProvenanceResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/10/22.
//

import Foundation

// MARK: - Respuesta
struct ProvenanceResponse: Codable {
    let parentesco: [Relationship]
    let origenFondos: [Origin]
    let nacionalidades: [Nationalities]
}

struct Relationship: Codable {
    let descripcion, idParentesco: String?
}

struct Origin: Codable {
    let idOrigen, descripcion: String?
}

struct Nationalities: Codable {
    let descripcion, idPais: String?
}


