//
//  City.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

// MARK: - Provincia
struct Provincias: Codable {
    let provincias: [City]
}

// MARK: - City
struct City: Codable {
    let idProvincia, provincia: String
    let cantones: [County]
}

// MARK: - County
struct County: Codable {
    let idCanton, canton: String
    let distritos: [District]
}

// MARK: - District
struct District: Codable {
    let idDistrito, distrito: String
}
