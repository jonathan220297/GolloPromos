//
//  GolloStoresViewModel.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 19/5/23.
//

import Foundation
import RxRelay

class GolloStoresViewModel {
    private let service = GolloService()
    
    var data: [ShopData] = []
    var states: [String] = []
    var shops: [ShopData] = []
    var shopSelected: ShopData?
    var stateSelected = ""
    
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
}
