//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation
import RxRelay

class SearchDocumentViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var accounts: [AccountsDetail] = []

    var reloadTableViewData: (()->())?

    func fetchCustomer(with documentType: String, documentId: String) -> BehaviorRelay<ThirdPartyData?> {
        let apiResponse: BehaviorRelay<ThirdPartyData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(SearchDocumentRequest(service: BaseServiceRequestParam<SearchDocumentServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.IS_GOLLO_CUSTOMER_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: SearchDocumentServiceRequest (
                    noCia: "10",
                    numeroIdentificacion: documentId,
                    tipoIdentificacion: documentType
                )
            )
        ))) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorMessage.accept(error.localizedDescription)
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }

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
