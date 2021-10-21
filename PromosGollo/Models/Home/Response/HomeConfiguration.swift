//
//  HomeConfiguration.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

// MARK: - HomeConfigurationData
struct HomeConfigurationData: Codable {
    let status: Bool?
    let message, mapId: String?
    let data: HomeConfiguration?
}

// MARK: - ResultMessage
struct ResultMessage: Codable {
    let estado: Bool?
    let mensaje, integrationId: String
}

// MARK: - HomeConfiguration
struct HomeConfiguration: Codable {
    let home: Home?
    let banners: [Banner]?
    let sections: [Section]?
}

// MARK: - Banner
struct Banner: Codable {
    let name: String?
    let position: Int?
    let isSlider, autoPlay: Bool?
    let height: Int?
    let backgroundColor: String?
    let columns: Int?
    let images: [ImageBanner]?
}

// MARK: - Image
struct ImageBanner: Codable {
    let linkType: Int?
    let linkValue: String?
    let image: String?
    let padding: Int?
}

// MARK: - Home
struct Home: Codable {
    let layout: String?
    let showMenu, showSearch, showLogo: Bool?
}

// MARK: - Section
struct Section: Codable {
    let name: String?
    let sectionType, listLayout, itemsToShow, position: Int?
    let category: Int?
    let linkValue: String?
    let linkType: Int?
}

enum SectionType: String {
    case recents = "Recent View"
    case products = "Productos"
}

enum LinkType: Int {
    case none = 0, category, product, url, appCategory, productData
}
