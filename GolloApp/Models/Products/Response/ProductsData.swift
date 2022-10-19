//
//  ProductsData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

// MARK: - ProductsData
public class ProductsData: NSObject, Codable {
    let productCode, descriptionDetailDescuento, descriptionDetailRegalia: String?
    let originalPrice: Double?
    let image: String?
    let montoBono, porcDescuento: Double?
    let brand, descriptionDetailBono, name: String?
    let modelo, endDate, simboloMoneda: String?
    let tieneBono: String?
    let tieneRegalia: String?
    let tieneDescuento: String?
    let id: Int?
    let montoDescuento: Double?
    let idUsuario, product: String?
    let idempresa: Int?
    let startDate: String?
    let precioFinal: Double?
    let productName: String?
    let tipoPromoApp: Int?
    let productsDataDescription: String?
    let averageRating: Double?
    let ratingCount: Int?

    enum CodingKeys: String, CodingKey {
        case productCode, descriptionDetailDescuento, descriptionDetailRegalia, originalPrice, image, montoBono, porcDescuento, brand, descriptionDetailBono, tieneBono, name, modelo, endDate, tieneRegalia, simboloMoneda, id, montoDescuento, idUsuario, product, idempresa, startDate, precioFinal, productName, tieneDescuento, tipoPromoApp, averageRating, ratingCount
        case productsDataDescription = "description"
    }
}


// MARK: - Image
public class Image: NSObject, Codable {
    let id, src: String?

    public init(id: String?, src: String?) {
        self.id = id
        self.src = src
    }
}

// MARK: - Store
public class Store: NSObject, Codable {
    let id: Int?
    let storeName, email, address, phone: String?
    let rating: Int?
    let gravatar, banner: String?
    let website: String?

    enum CodingKeys: String, CodingKey {
        case id
        case storeName = "store_name"
        case email, address, phone, rating, gravatar, banner, website
    }

    public init(id: Int?, storeName: String?, email: String?, address: String?, phone: String?, rating: Int?, gravatar: String?, banner: String?, website: String?) {
        self.id = id
        self.storeName = storeName
        self.email = email
        self.address = address
        self.phone = phone
        self.rating = rating
        self.gravatar = gravatar
        self.banner = banner
        self.website = website
    }
}
