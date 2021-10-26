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
    var filterData: [FilterData] = []

    var reloadTableViewData: (()->())?

    func fetchFilterStores() -> BehaviorRelay<[FilterData]?> {
        let apiResponse: BehaviorRelay<[FilterData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(FilterRequest(service: BaseServiceRequestParam<FilterServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.OFFER_CAT_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: FilterServiceRequest (
                    idCompania: "10"
                )
            )
        ))) { response in
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
}
