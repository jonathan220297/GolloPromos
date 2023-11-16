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
    let preaprobado: PreapprovedInfo?
}

// MARK: - Banner
struct Banner: Codable {
    let borderColor: String?
    let position: Int?
    let isSlider: Bool?
    let autoPlayDelay, columns, borderWidth, borderRadio: Int?
    let autoPlay: Bool?
    let height: Int?
    let indFomo: Bool?
    let endFomo: String?
    let images: [ImageBanner]?
    let name: String?
    var uiHeight: CGFloat? = 0.0
}

// MARK: - Image
struct ImageBanner: Codable {
    let taxonomia: Int?
    let linkValue: String?
    let image: String?
    let linkType: Int?
}

// MARK: - Home
struct Home: Codable {
    let showSearch, showMenu, showLogo: Bool?
    let layout: String?
}

// MARK: - Section
struct Section: Codable {
    let indCategoria: Bool?
    let pricipalImage: String?
    let position, columns: Int?
    let autoPlayDelay: Int?
    let borderWidth, borderRadio: Int?
    let productos: [Product]?
    let endFOMO: String?
    let linkValue, linkTax: Int?
    let name: String?
    let isSlider: Bool?
    let itemsToShow: Int?
    let autoPlay, indFOMO: Bool?
    let sectionType: Int?
    let height, linkType: Int?
    let borderColor: String?
    let secondaryImage: String?
    let categorias: [Categories]?
    let vertical: Bool?
}

// MARK: - PreapprovedInfo
struct PreapprovedInfo: Codable {
    let indPopup: Int?
    let image: String?
    let nombreCliente: String?
    let monto: Double?
    let fechaInicio: String?
    let fechaFin: String?
    let texto: String?
    let popup: String?
}

// MARK: - Categories
class Categories: Codable {
    init(extra: Bool? = nil, idCategoria: Int? = nil, imagen: String? = nil, descripcion: String? = nil, logo: String? = nil, idTaxonomia: Int? = nil) {
        self.extra = extra
        self.idCategoria = idCategoria
        self.imagen = imagen
        self.descripcion = descripcion
        self.logo = logo
        self.idTaxonomia = idTaxonomia
    }
    
    var extra: Bool?
    let idCategoria: Int?
    let imagen: String?
    let descripcion: String?
    let logo: String?
    let idTaxonomia: Int?
}

enum LinkType: Int {
    case none = 0, category, product, url, appCategory, productData
}

// MARK: - Producto
class Product: Codable {
    init(productCode: String? = nil, descriptionDetailDescuento: String? = nil, descriptionDetailRegalia: String? = nil, originalPrice: Double? = nil, image: String? = nil, montoBono: Double? = nil, porcDescuento: Double? = nil, brand: String? = nil, descriptionDetailBono: String? = nil, tieneBono: String? = nil, name: String? = nil, modelo: String? = nil, endDate: String? = nil, tieneRegalia: String? = nil, simboloMoneda: SimboloMoneda? = nil, id: Int? = nil, montoDescuento: Double? = nil, idUsuario: String? = nil, product: String? = nil, idEmpresa: Int? = nil, startDate: String? = nil, precioFinal: Double? = nil, productName: String? = nil, tieneDescuento: String? = nil, tipoPromoApp: Int? = nil, productoDescription: String? = nil, muestraDescuento: String? = nil, tiene2x1: String? = nil, tieneNuevo: String? = nil, tieneTopVentas: String? = nil, tieneExclusivo: String? = nil, tienetranspGratis: String? = nil, indMostrarTop: Bool? = nil, extra: Bool? = nil, idCategoria2: Int? = nil) {
        self.productCode = productCode
        self.descriptionDetailDescuento = descriptionDetailDescuento
        self.descriptionDetailRegalia = descriptionDetailRegalia
        self.originalPrice = originalPrice
        self.image = image
        self.montoBono = montoBono
        self.porcDescuento = porcDescuento
        self.brand = brand
        self.descriptionDetailBono = descriptionDetailBono
        self.tieneBono = tieneBono
        self.name = name
        self.modelo = modelo
        self.endDate = endDate
        self.tieneRegalia = tieneRegalia
        self.simboloMoneda = simboloMoneda
        self.id = id
        self.montoDescuento = montoDescuento
        self.idUsuario = idUsuario
        self.product = product
        self.idEmpresa = idEmpresa
        self.startDate = startDate
        self.precioFinal = precioFinal
        self.productName = productName
        self.tieneDescuento = tieneDescuento
        self.tipoPromoApp = tipoPromoApp
        self.productoDescription = productoDescription
        self.muestraDescuento = muestraDescuento
        self.tiene2x1 = tiene2x1
        self.tieneNuevo = tieneNuevo
        self.tieneTopVentas = tieneTopVentas
        self.tieneExclusivo = tieneExclusivo
        self.tienetranspGratis = tienetranspGratis
        self.indMostrarTop = indMostrarTop
        self.extra = extra
        self.idCategoria2 = idCategoria2
    }
    
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
    var extra: Bool?
    var idCategoria2: Int?
    
    enum CodingKeys: String, CodingKey {
        case productCode, descriptionDetailDescuento, descriptionDetailRegalia, originalPrice, image, montoBono, porcDescuento, brand, descriptionDetailBono, tieneBono, name, modelo, endDate, tieneRegalia, simboloMoneda, id, montoDescuento, idUsuario, product
        case idEmpresa = "IdEmpresa, idempresa"
        case startDate, precioFinal, productName, tieneDescuento, tipoPromoApp, muestraDescuento
        case productoDescription = "description"
        case tiene2x1, tieneNuevo, tieneTopVentas, tieneExclusivo, tienetranspGratis, indMostrarTop, idCategoria2
    }
}

enum SimboloMoneda: String, Codable {
    case empty = "¢"
}
