//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 20/9/21.
//

import Foundation
import RxRelay

class FilterViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var filterData: [StoreData] = []
    var groupStores: [String?: [StoreData]] = [:]
    var storesSelected: [StoreData] = []

    var reloadTableViewData: (()->())?

    func fetchFilterStores() -> BehaviorRelay<[StoreData]?> {
        let apiResponse: BehaviorRelay<[StoreData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[StoreData], FilterServiceRequest>(
            service: BaseServiceRequestParam<FilterServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.OFFER_STORES_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: FilterServiceRequest (
                        idCompania: "10"
                    )
                )
            )
        )) { response in
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
    
    func groupStores(with stores: [StoreData]) {
        groupStores = Dictionary(grouping: stores, by: { $0.provincia })
        log.debug("groupStores: \(groupStores)")
    }
    
    func findStores(by state: String,
                    completion: @escaping(_ result: Bool) -> ()) {
        storesSelected.removeAll()
        let filter = groupStores.filter({ (dic) -> Bool in
            dic.key == state
        })
        let stores = Array(filter.values)
        for store in stores {
            storesSelected.append(contentsOf: store)
        }
        completion(true)
    }
}
