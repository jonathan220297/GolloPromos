//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 3/10/21.
//

import Foundation
import RxRelay

class StatusViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var status: Status = Status()

    var reloadTableViewData: (()->())?

    func fetchStatus(with documentType: String, documentId: String) -> BehaviorRelay<Status?> {
        let apiResponse: BehaviorRelay<Status?> = BehaviorRelay(value: nil)
        service.callWebService(StatusRequest(service: BaseServiceRequestParam<StatusServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.STATUS_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: UserManager.shared.userData?.uid ?? "",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: StatusServiceRequest (
                    tipoId: documentType,
                    idCliente: documentId,
                    empresa: 10,
                    idCentro: ""
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
