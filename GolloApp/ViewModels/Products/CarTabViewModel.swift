//
//  CarTabViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class CarTabViewModel {
    let carManager = CarManager.shared
    private let defaults = UserDefaults.standard
    
    var car: [CartItemDetail] = []
    var total = 0.0
    var bonus = 0.0
    
    func setItemsToCarManager() {
        //OrderItem
        var i = 1
        for item in car {
            carManager.car.append(
                OrderItem(
                    cantidad: item.cantidad,
                    mesesExtragar: item.mesesExtragar,
                    idLinea: i,
                    descripcion: item.descripcion,
                    descuento: item.mesesExtragar,
                    montoDescuento: item.montoDescuento,
                    montoExtragar: item.montoExtragar,
                    porcDescuento: item.porcDescuento,
                    precioExtendido: item.precioExtendido,
                    precioUnitario: item.precioUnitario,
                    sku: item.sku,
                    tipoSku: 1,
                    montoBonoProveedor: item.montoBonoProveedor,
                    codRegalia: item.codRegalia,
                    descRegalia: item.descRegalia
                )
            )
            i += 1
        }
    }

    func getTotalItems() -> Int {
        var i = 0
        for c in car {
            i += 1 * c.cantidad
        }
        return i
    }
    
    func deleteCarManagerTypeState() {
        defaults.removeObject(forKey: "carManagetTypeStarted")
    }
    
}
