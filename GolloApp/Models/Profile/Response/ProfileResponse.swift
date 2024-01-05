//
//  ProfileResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 22/5/23.
//

import Foundation

struct ProfileResponse: Codable {
    let perfil: UserData?
    let indExiste: String?
    let indAsociado: Int?
}
