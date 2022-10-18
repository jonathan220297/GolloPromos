//
//  MasterSection.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import Foundation

class MasterSection {
    init(position: Int? = nil, name: String? = nil, height: Double? = nil, banner: Banner? = nil, link: Int? = nil, product: [Product]? = nil) {
        self.position = position
        self.name = name
        self.height = height
        self.banner = banner
        self.link = link
        self.product = product
    }
    
    var position: Int?
    var name: String?
    var height: Double?
    var banner: Banner?
    var link: Int?
    var product: [Product]?
}
