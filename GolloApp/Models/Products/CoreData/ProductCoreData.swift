//
//  ProductsCoreData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

struct ProductCoreData {
    let id: String
    let json: String
    let dateSaved: Date?

    init(id: String, json: String) {
        self.id = id
        self.json = json
        self.dateSaved = nil
    }

    init(id: String, json: String, dataSaved: Date) {
        self.id = id
        self.json = json
        self.dateSaved = dataSaved
    }
}

