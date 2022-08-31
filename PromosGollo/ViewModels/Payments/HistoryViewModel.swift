//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation
import RxRelay

class HistoryViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var status: [AppTransaction] = []

    var reloadTableViewData: (()->())?

    func fetchHistoryTransactions(with startDate: String, endDate: String) -> BehaviorRelay<[AppTransaction]?> {
        let apiResponse: BehaviorRelay<[AppTransaction]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(HistoryRequest(service: BaseServiceRequestParam<HistoryServiceRequest>(
            servicio: ServicioParam(
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.APP_PAYMENT_HISTORY.rawValue),
                parametros: HistoryServiceRequest (
                    idMovimiento: "",
                    fechaInicial: startDate,
                    fechaFinal: endDate,
                    identificacionCliente: "204880675"
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
