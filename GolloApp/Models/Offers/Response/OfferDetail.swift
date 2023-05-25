//
//  OfferDetail.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/9/22.
//

import Foundation

struct OfferDetail : Codable {
    let articulo: Article?
}

struct Article : Codable {
    let sku, codigoReferencia, codigo, nombre, especificaciones: String?
    let urlImagen, marca, modelo: String?
    let montoBonoProveedor, precioDescuento, montoDescuento, precio: String?
    let descripcionDetalle: String?
    let startDate, endDate: String?
    let regalias: Royalties?
    let stock: [Stock]?
    let extragarantia: [Warranty]?
    let imagenes: [ArticleImages]?
    let complementos: [Offers]?
}

struct Royalties: Codable {
    let descripcion, codigo: String?
}

struct Stock: Codable {
    let bodega: String?
    let existencias: Int?
}

struct Warranty: Codable {
    let plazoMeses: Int?
    let porcentaje, montoExtragarantia, impuestoExtragarantia: Double?
    let titulo: String?
}

struct ArticleImages: Codable {
    let tipo: Int?
    let imagen: String?
}
