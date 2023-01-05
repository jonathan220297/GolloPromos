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
    var bonus = 0.0
    var car: [OrderItem] = []
    var shippingMethod: ShippingMethodData?
    var paymentMethodSelected: PaymentMethodResponse?
    var paymentMethod: [PaymentMethod] = []
    var deliveryInfo: DeliveryInfo?
    var nationality: String?
    var kinship: String?
    var fundsSource: String?
    
    func emptyCar() -> Bool {
        car.removeAll()
        shippingMethod = nil
        paymentMethodSelected = nil
        paymentMethod.removeAll()
        deliveryInfo = nil
        nationality = nil
        kinship = nil
        fundsSource = nil
        return CoreDataService().deleteAllItems()
    }
    
    func emptyCarWithCoreData() {
        car.removeAll()
        shippingMethod = nil
        paymentMethodSelected = nil
        paymentMethod.removeAll()
        deliveryInfo = nil
        nationality = nil
        kinship = nil
        fundsSource = nil
    }
}
