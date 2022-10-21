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
    let precio, montoDescuento, montoBonoProveedor, precioDescuento: Double?
    let regalias: Royalties?
    let stock: [Stock]?
    let extraGarantia: [Warranty]?
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
