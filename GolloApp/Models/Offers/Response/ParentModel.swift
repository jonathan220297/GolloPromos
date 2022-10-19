//
//  ParentModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import Foundation

class ParentModel: Codable {
    var code: String = ""
    var name : String = ""
    var image: Int?
    var children: [Offers?] = []

    init(code: String, name: String, image: Int, children: [Offers?]) {
        self.code = code
        self.name = name
        self.image = image
        self.children = children
    }
}
