//
//  MenuWishesData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/9/22.
//

import Foundation

struct MenuTabData: Codable {
    let title: String
    let items: [ItemTabData]
}

struct ItemTabData: Codable {
    let id: Int
    let image, title, subtitle: String
}
