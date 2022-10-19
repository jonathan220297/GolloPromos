//
//  ProductVariationResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

// MARK: - ProductVariationResponse
struct ProductVariationResponse: Codable {
    let variationID, sku, originalPrice, salePrice: String?
    let discountPercentage: String?
    let onSale, inStock: Bool?
    let stockQuantity: Int?
    let image: String?
    let visible: Bool?
    let attributes: [Attribute]?

    enum CodingKeys: String, CodingKey {
        case variationID = "variationId"
        case sku, originalPrice, salePrice, discountPercentage, onSale, inStock, stockQuantity, image, visible, attributes
    }
}

// MARK: - Attribute
struct Attribute: Codable {
    let name, value: String?
}

struct AttributeAux {
    let variationID, name, value: String?
}
