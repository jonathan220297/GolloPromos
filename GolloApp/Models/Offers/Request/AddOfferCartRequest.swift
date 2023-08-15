//
//  AddOfferCartRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 20/9/22.
//

import Foundation

struct AddOfferCartRequest : APIRequest {

    public typealias Response = OfferCartDetail

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<AddOfferCartServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct AddOfferCartServiceRequest: Codable {
    var detalle: [CartItemDetail]?
    var idCliente: String
}

class CartItemDetail: Codable {
    init(idCarItem: UUID? = nil, urlImage: String? = nil, cantidad: Int, idLinea: Int, mesesExtragar: Int, descripcion: String, sku: String, descuento: Double, montoDescuento: Double, montoExtragar: Double, porcDescuento: Double, precioExtendido: Double, precioUnitario: Double, montoBonoProveedor: Double?, codRegalia: String?, descRegalia: String?, warranty: [Warranty] = [], expenses: [OtherExpenses] = [], totalExpenses: Double?, indVMI: Int) {
        self.idCarItem = idCarItem
        self.urlImage = urlImage
        self.cantidad = cantidad
        self.idLinea = idLinea
        self.mesesExtragar = mesesExtragar
        self.descripcion = descripcion
        self.sku = sku
        self.descuento = descuento
        self.montoDescuento = montoDescuento
        self.montoExtragar = montoExtragar
        self.porcDescuento = porcDescuento
        self.precioExtendido = precioExtendido
        self.precioUnitario = precioUnitario
        self.montoBonoProveedor = montoBonoProveedor
        self.codRegalia = codRegalia
        self.descRegalia = descRegalia
        self.warranty = warranty
        self.expenses = expenses
        self.totalExpenses = totalExpenses
        self.indVMI = indVMI
    }
    
    init(cantidad: Int, idLinea: Int, mesesExtragar: Int, descripcion: String, sku: String, descuento: Double, montoDescuento: Double, montoExtragar: Double, porcDescuento: Double, precioExtendido: Double, precioUnitario: Double, montoBonoProveedor: Double?, codRegalia: String?, descRegalia: String?, totalExpenses: Double?, indVMI: Int) {
        self.cantidad = cantidad
        self.idLinea = idLinea
        self.mesesExtragar = mesesExtragar
        self.descripcion = descripcion
        self.sku = sku
        self.descuento = descuento
        self.montoDescuento = montoDescuento
        self.montoExtragar = montoExtragar
        self.porcDescuento = porcDescuento
        self.precioExtendido = precioExtendido
        self.montoBonoProveedor = montoBonoProveedor
        self.precioUnitario = precioUnitario
        self.codRegalia = codRegalia
        self.descRegalia = descRegalia
        self.totalExpenses = totalExpenses
        self.indVMI = indVMI
    }
    
    var idCarItem: UUID?
    var urlImage: String?
    var cantidad, idLinea, mesesExtragar: Int
    var descripcion, sku: String
    var descuento, montoDescuento, montoExtragar, porcDescuento, precioExtendido, precioUnitario: Double
    var montoBonoProveedor: Double?
    var codRegalia: String?
    var descRegalia: String?
    var warranty: [Warranty]?
    var expenses: [OtherExpenses]?
    var totalExpenses: Double?
    var indVMI: Int
    var showingInformation: Bool = false
}

