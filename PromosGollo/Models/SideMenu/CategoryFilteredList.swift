//
//  CategoryFilteredList.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import Foundation

struct CategoryFilteredList: Codable {
    let id, count: Int
    let name: String
    let description, image: String?
    let categories: [SubCategoryItem]
    var isOpened: Bool = false
}

struct SubCategoryItem: Codable {
    let id, count: Int
    let name: String
    let description, image: String?
}
