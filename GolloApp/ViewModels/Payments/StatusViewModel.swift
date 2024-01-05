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
    var account: [AccountData] = []

    var reloadTableViewData: (()->())?

    func fetchStatus(with documentType: String, documentId: String) -> BehaviorRelay<StatusData?> {
        let apiResponse: BehaviorRelay<StatusData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(StatusRequest(service: BaseServiceRequestParam<StatusServiceRequest>(
            servicio: ServicioParam(
//                encabezado: Encabezado(
//                    idProceso: GOLLOAPP.STATUS_PROCESS_ID.rawValue,
//                    idDevice: getDeviceID(),
//                    idUsuario: UserManager.shared.userData?.uid ?? "",
//                    timeStamp: String(Date().timeIntervalSince1970),
//                    idCia: 10,
//                    token: getToken(),
//                    integrationId: nil
//                ),
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.STATUS_PROCESS_ID.rawValue),
                parametros: StatusServiceRequest (
                    tipoId: documentType,
                    idCliente: documentId,
                    empresa: 10,
                    idCentro: "205"
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
}
