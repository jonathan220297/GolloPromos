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
    var stateSelected = ""
    var methodSelected: ShippingMethodData?
    
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
    func setShippingMethods(_ selected: Bool) {
        methods.append(
            ShippingMethodData(
                cargoCode: "-1",
                shippingType: "Recoger en tienda",
                shippingDescription: "Recoger sus productos en cualquiera de nuestras tiendas en todo el país",
                cost: 0.0,
                selected: selected
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

    func fetchDeliveryMethods(idState: String, idCounty: String, idDistrict: String) -> BehaviorRelay<DeliveryMethodsResponse?> {
        let apiResponse: BehaviorRelay<DeliveryMethodsResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<DeliveryMethodsResponse?, DeliveryMethodsServiceRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<DeliveryMethodsServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.FREIGHTS_PROCESS_ID.rawValue
                        ),
                        parametros: DeliveryMethodsServiceRequest(
                            idCanton: idCounty,
                            idDistrito: idDistrict,
                            idProvincia: idState,
                            monto: carManager.total
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
                    self.errorMessage.accept(error.errorDescription)
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
        var deliveryType = "20"
        if methodSelected?.cargoCode == "-1" {
            deliveryType = "20"
        } else {
            deliveryType = methodSelected?.cargoCode ?? ""
        }
        carManager.shippingMethod = methodSelected
        carManager.deliveryInfo?.lugarDespacho = shopSelected?.idTienda ?? ""
        carManager.deliveryInfo?.tipoEntrega = deliveryType
        carManager.deliveryInfo?.codigoFlete = carManager.shippingMethod?.cargoCode ?? "-1"
        carManager.deliveryInfo?.montoFlete = carManager.shippingMethod?.cost ?? 0.0
    }
}
