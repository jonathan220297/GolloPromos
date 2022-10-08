//
//  ShippingMethodViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation
import RxRelay

class ShippingMethodViewModel {
    private let service = GolloService()
    let carManager = CarManager.shared
    
    var methods: [ShippingMethodData] = []
    var data: [ShopData] = []
    var states: [String] = []
    var shops: [ShopData] = []
    var shopSelected: ShopData?
    
    init() {
        setShippingMethods()
    }
    
    func setShippingMethods() {
        methods.append(
            ShippingMethodData(
                shippingType: "Recoger en tienda",
                shippingDescription: "Recoger sus productos en cualquiera de nuestras tiendas en todo el país",
                cost: 0.0
            )
        )
    }
    
    func fetchShops() -> BehaviorRelay<[ShopData]?> {
        let apiResponse: BehaviorRelay<[ShopData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<[ShopData]?, ShopsListRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<ShopsListRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.OFFER_STORES_PROCESS_ID.rawValue
                        ),
                        parametros: ShopsListRequest(
                            idCompania: "10"
                        )
                    )
                )
            )
        ) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
    
    func processStates(with data: [ShopData]) {
        for item in data {
            if !states.contains(where: { state in
                state == item.provincia
            }) {
                states.append(item.provincia ?? "")
            }
        }
        states.sort { state1, state2 in
            state1 < state2
        }
    }
    
    func processShops(with state: String) {
        shops = data.filter({ data in
            data.provincia == state
        })
    }
    
    func processShippingMethod() {
        carManager.deliveryInfo?.lugarDespacho = shopSelected?.idTienda ?? ""
        carManager.deliveryInfo?.tipoEntrega = "20"
    }
}