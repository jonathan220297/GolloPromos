//
//  ProductsData.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

// MARK: - ProductsData
public class ProductsData: NSObject, Codable {
    let productID, name, productDescription, mainImage: String?
    let sku, salePrice, variationID, originalPrice: String?
    let discountPercentage: String?
    let inStock: Bool?
    let averageRating: String?
    let ratingCount: Int?
    let store: Store?
    let images: [Image]?

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case name
        case productDescription = "description"
        case mainImage, sku, salePrice
        case variationID = "variationId"
        case originalPrice, discountPercentage, inStock, averageRating, ratingCount, store, images
    }

    public init(productID: String?, name: String?, productDescription: String?, mainImage: String?, sku: String?, salePrice: String?, variationID: String?, originalPrice: String?, discountPercentage: String?, inStock: Bool?, averageRating: String?, ratingCount: Int?, store: Store?, images: [Image]?) {
        self.productID = productID
        self.name = name
        self.productDescription = productDescription
        self.mainImage = mainImage
        self.sku = sku
        self.salePrice = salePrice
        self.variationID = variationID
        self.originalPrice = originalPrice
        self.discountPercentage = discountPercentage
        self.inStock = inStock
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.store = store
        self.images = images
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
