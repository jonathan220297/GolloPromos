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
    var customerInfo: CustomerInfo? = nil

    var reloadTableViewData: (()->())?

    func fetchCustomer(with documentType: String, documentId: String) -> BehaviorRelay<CustomerInfo?> {
        let apiResponse: BehaviorRelay<CustomerInfo?> = BehaviorRelay(value: nil)
        service.callWebService(SearchDocumentRequest(service: BaseServiceRequestParam<SearchDocumentServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.IS_GOLLO_CUSTOMER_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: UserManager.shared.userData?.uid ?? "",
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
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}
