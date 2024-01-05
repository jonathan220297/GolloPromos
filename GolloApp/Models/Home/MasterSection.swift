//
//  MasterSection.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import Foundation

class MasterSection {
    init(
        vertical: Bool,
        position: Int? = nil,
        name: String? = nil,
        height: Double? = nil,
        banner: Banner? = nil,
        link: Int? = nil,
        tax: Int? = nil,
        product: [Product]? = nil,
        categories: [Categories]? = nil,
        isPreapproved: Bool?,
        preapprovedDescription: NSAttributedString? = nil,
        preapprovedImage: String? = nil
    ) {
        self.vertical = vertical
        self.position = position
        self.name = name
        self.height = height
        self.banner = banner
        self.link = link
        self.tax = tax
        self.product = product
        self.categories = categories
        self.isPreapproved = isPreapproved
        self.preapprovedDescription = preapprovedDescription
        self.preapprovedImage = preapprovedImage
    }
    
    var vertical: Bool
    var position: Int?
    var name: String?
    var height: Double?
    var banner: Banner?
    var link: Int?
    var tax: Int?
    var product: [Product]?
    var categories: [Categories]?
    var isPreapproved: Bool?
    var preapprovedDescription: NSAttributedString?
    var preapprovedImage: String?
}
