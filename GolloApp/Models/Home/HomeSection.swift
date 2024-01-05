//
//  HomeSection.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

class HomeSection {
    var name: String?
    var position: Int?
    var isSection = false
    var banner: Banner?
    var section: Section?
    var signUp: Bool?

    init(name: String, position: Int, banner: Banner) {
        self.name = name
        self.position = position
        self.isSection = false
        self.banner = banner
        self.section = nil
    }

    init(name: String, position: Int, section: Section) {
        self.name = name
        self.position = position
        self.isSection = true
        self.banner = nil
        self.section = section
    }
    
    init(name: String, position: Int, signUp: Bool) {
        self.name = name
        self.position = position
        self.isSection = true
        self.banner = nil
        self.section = nil
        self.signUp = signUp
    }
}

enum ListLayout: Int {
    case none = 0, oneColumn, twoColumns, threeColumns
}
