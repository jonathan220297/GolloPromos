//
//  CarManager.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation

class CarManager {
    static let shared = CarManager()
    
    var total = 0.0
    var car: [OrderItem] = []
    var shippingMethod: ShippingMethodData?
    var paymentMethodSelected: PaymentMethodResponse?
    var paymentMethod: [PaymentMethod] = []
    var deliveryInfo: DeliveryInfo?
    
    func emptyCar() -> Bool {
        car.removeAll()
        shippingMethod = nil
        paymentMethodSelected = nil
        paymentMethod.removeAll()
        deliveryInfo = nil
        return CoreDataService().deleteAllItems()
    }
}
