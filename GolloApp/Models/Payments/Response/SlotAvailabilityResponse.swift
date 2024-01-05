//
//  SlotAvailabilityResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 2/1/24.
//

import Foundation

// MARK: - Respuesta
struct SlotAvailabilityResponse: Codable {
    let id: String?
    let from, to: String?
    let store: StoreInstaleap?
    let description, operational_model: String?
    let expires_at: String?
}

struct StoreInstaleap: Codable {
    let id, name: String?
}
