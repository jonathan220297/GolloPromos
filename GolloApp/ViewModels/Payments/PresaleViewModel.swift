//
//  PresaleViewModel.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 16/11/23.
//

import Foundation
import RxSwift
import RxRelay

class PresaleViewModel {
    private let service = GolloService()
    let userManager = UserManager.shared
    let carManager = CarManager.shared
    
    var subTotal = 0.0
    var shipping = 0.0
    var bonus = 0.0
    var presaleDetail: PresaleResponse? = nil
    var currentTerm: CrediGolloTerm? = nil
    var selectedTerm: Int = 0
    var currentPrima: Double = 0.0
    
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
    func fetchCrediGolloTerms() -> BehaviorRelay<PresaleResponse?> {
        let apiResponse: BehaviorRelay<PresaleResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<PresaleResponse?, PresaleServiceRequest>(
            service: BaseServiceRequestParam<PresaleServiceRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.GET_CREDIT_TERMS_PROCESS_ID.rawValue),
                    parametros: PresaleServiceRequest(
                        centro: "205",
                        numIdentificacion: Variables.userProfile?.numeroIdentificacion ?? "",
                        tipoIdentificacion: Variables.userProfile?.tipoIdentificacion ?? "",
                        monto: getTotalItemsAmount() + getTotalExpenses(),
                        montoCSR: getTotalCSRAmount(),
                        montoBono: getBonoTotalAmount(),
                        montoFlete: getDeliveryAmountFromCart(),
                        montoDescuento: getTotalDescuentos(),
                        prima: currentPrima + getBonoTotalAmount(),
                        articulos: getItems()
                    )
                )
            )
        )) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorMessage.accept(error.localizedDescription)
                }
            }
        }
        return apiResponse
    }
    
    private func getTotalItemsAmount() -> Double {
        let products = carManager.carProductsDetail
        return products.map { $0.precioUnitario * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getTotalCSRAmount() -> Double {
        let products = carManager.carProductsDetail
        return products.map { $0.montoExtragar * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getBonoTotalAmount() -> Double {
        let products = carManager.carProductsDetail
        return products.map { ($0.montoBonoProveedor ?? 0.0) * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getDeliveryAmountFromCart() -> Double {
        return carManager.shippingMethod?.cost ?? 0.0
    }
    
    private func getTotalDescuentos() -> Double {
        let products = carManager.carProductsDetail
        return products.map { $0.montoDescuento * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getTotalExpenses() -> Double {
        let products = carManager.carProductsDetail
        return products.map { ($0.totalExpenses ?? 0.0) * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getItems() -> [CreditItem] {
        var items: [CreditItem] = []
        let products = carManager.carProductsDetail
        products.forEach { item in
            items.append(
                CreditItem(
                    sku: item.sku,
                    total: (item.montoDescuento * Double(item.cantidad))
                )
            )
        }
        return items
    }
    
    func getTotalAmountFromCart() -> Double {
        let amount = getTotalDescuentos()
        let golloPlus = getTotalCSRAmount()
        let bono = getBonoTotalAmount()
        let expenses = getTotalExpenses()
        
        return amount + golloPlus + bono + expenses
    }
}
