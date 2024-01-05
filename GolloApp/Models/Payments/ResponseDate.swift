//
//  ResponseDate.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 2/1/24.
//

import Foundation

struct ResponseDate: Codable, Hashable {
    let day, month, numberDay: String?
    let slotDate: Date?
    var selected: Bool? = false
}

struct ResponseHours: Codable, Hashable {
    let idSlot: String?
    let fromDate, fromHour: String?
    let toDate, toHour: String?
    var selected: Bool = false
}
