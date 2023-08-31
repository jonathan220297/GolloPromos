//
//  ValidateProfileResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 18/8/23.
//

import Foundation

struct ValidateProfileResponse: Codable {
    let perfil: AffiliationProfile?
    let indExiste: String?
}

struct AffiliationProfile: Codable {
    let pinValidacion, emailValidacion: String
    let corporacion, tipoIdentificacion, numeroIdentificacion: String
    let nombre, apellido1: String
    let apellido2, correoElectronico: String?
    let idUsuarioActual: String
}
