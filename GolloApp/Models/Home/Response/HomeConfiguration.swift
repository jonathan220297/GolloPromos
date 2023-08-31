//
//  HomeConfiguration.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit

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
//    let name: String?
//    let position: Int?
//    let isSlider, autoPlay: Bool?
//    let height: Int?
//    let backgroundColor: String?
//    let columns: Int?
//    let images: [ImageBanner]?
    let autoPlay: Bool?
    let position, height, columns: Int?
    let images: [ImageBanner]?
    let isSlider: Bool?
    let name: String?
    let autoPlayDelay: Int?
    var uiHeight: CGFloat? = 0.0
}

// MARK: - Image
struct ImageBanner: Codable {
    let padding: Int?
    let linkValue: String?
    let image: String?
    let linkType: Int?
    let taxonomia: Int?
}

// MARK: - Home
struct Home: Codable {
    let showSearch, showMenu, showLogo: Bool?
    let layout: String?
}

// MARK: - Section
struct Section: Codable {
//    let name: String?
//    let sectionType, listLayout, itemsToShow, position: Int?
//    let category: Int?
//    let linkValue: String?
//    let linkType: Int?
    let linkTax, position, itemsToShow, linkType: Int?
    let sectionType: Int?
    let linkValue: Int?
    let name: String?
    let productos: [Product]?
}

enum SectionType: String {
    case recents = "Recent View"
    case products = "Productos"
}

enum LinkType: Int {
    case none = 0, category, product, url, appCategory, productData
}

// MARK: - Producto
struct Product: Codable {
    let productCode: String?
    let descriptionDetailDescuento, descriptionDetailRegalia: String?
    let originalPrice: Double?
    let image: String?
    let montoBono, porcDescuento: Double?
    let brand: String?
    let descriptionDetailBono: String?
    let tieneBono, name, modelo: String?
    let endDate: String?
    let tieneRegalia: String?
    let simboloMoneda: SimboloMoneda?
    let id: Int?
    let montoDescuento: Double?
    let idUsuario, product: String?
    let idEmpresa: Int?
    let startDate: String?
    let precioFinal: Double?
    let productName, tieneDescuento: String?
    let tipoPromoApp: Int?
    let productoDescription: String?
    let muestraDescuento: String?
    let tiene2x1, tieneNuevo, tieneTopVentas, tieneExclusivo, tienetranspGratis: String?
    let indMostrarTop: Bool?
    

    enum CodingKeys: String, CodingKey {
        case productCode, descriptionDetailDescuento, descriptionDetailRegalia, originalPrice, image, montoBono, porcDescuento, brand, descriptionDetailBono, tieneBono, name, modelo, endDate, tieneRegalia, simboloMoneda, id, montoDescuento, idUsuario, product
        case idEmpresa = "IdEmpresa, idempresa"
        case startDate, precioFinal, productName, tieneDescuento, tipoPromoApp, muestraDescuento
        case productoDescription = "description"
        case tiene2x1, tieneNuevo, tieneTopVentas, tieneExclusivo, tienetranspGratis, indMostrarTop
    }
}

enum SimboloMoneda: String, Codable {
    case empty = "¢"
}
