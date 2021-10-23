//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation
import RxRelay

class AccountsViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var accounts: [AccountsDetail] = []

    var reloadTableViewData: (()->())?

    func fetchAccounts(with documentType: String, documentId: String) -> BehaviorRelay<[AccountsDetail]?> {
        let apiResponse: BehaviorRelay<[AccountsDetail]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(AccountsRequest(service: BaseServiceRequestParam<AccountsServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.ACTIVE_ACCOUNTS_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: AccountsServiceRequest (
                    tipoId: documentType,
                    idCliente: documentId,
                    empresa: "10",
                    idCentro: ""
                )
            )
        ))) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response.cuentas)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}
