//
//  SideMenuViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import RxRelay

class SideMenuViewModel {
    private let service = GolloService()
    let userManager = UserManager.shared

    func fetchUnreadNotifications() -> BehaviorRelay<UnreadNotificationData?> {
        let apiResponse: BehaviorRelay<UnreadNotificationData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<UnreadNotificationData, UnreadNotificationServiceRequest>(
            service: BaseServiceRequestParam<UnreadNotificationServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.UNREAD_NOTIFICATIONS_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: UnreadNotificationServiceRequest (
                        idCliente: UserManager.shared.userData?.uid ?? ""
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
}

