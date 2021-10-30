//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation
import RxRelay

class AccountItemsViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var items: [Items] = []

    var reloadTableViewData: (()->())?

    func fetchAccountItems(with accountType: String, accountId: String) -> BehaviorRelay<AccountsItemResponse?> {
        let apiResponse: BehaviorRelay<AccountsItemResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(AccountItemsRequest(service: BaseServiceRequestParam<AccountItemsServiceRequest>(
            servicio: ServicioParam(
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.ACCOUNT_ITEMS_PROCESS_ID.rawValue),
                parametros: AccountItemsServiceRequest (
                    empresa: "10",
                    idCuenta: accountId,
                    tipoMovimiento: accountType
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
