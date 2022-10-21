//
//  CarTabViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class CarTabViewModel {
    let carManager = CarManager.shared
    
    var car: [CartItemDetail] = []
    var total = 0.0
    
    func setItemsToCarManager() {
        //OrderItem
        for item in car {
            carManager.car.append(
                OrderItem(
                    cantidad: item.cantidad,
                    mesesExtragar: item.mesesExtragar,
                    idLinea: item.idLinea,
                    descripcion: item.descripcion,
                    descuento: item.mesesExtragar,
                    montoDescuento: item.montoDescuento,
                    montoExtragar: item.montoExtragar,
                    porcDescuento: item.porcDescuento,
                    precioExtendido: item.precioExtendido,
                    precioUnitario: item.precioUnitario,
                    sku: item.sku,
                    tipoSku: 1,
                    montoBonoProveedor: item.montoBonoProveedor ?? 0.0,
                    codRegalia: item.codRegalia,
                    descRegalia: item.descRegalia
                )
            )
        }
    }
}
