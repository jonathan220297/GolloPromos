//
//  NotificationsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import RxRelay

class NotificationsViewModel {
    private let service = GolloService()
    let userManager = UserManager.shared

    var NotificationsArray: [NotificationsData] = []
    var errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")

    var page = 1
    var fetchingMore = false

    func fetchNotifications() -> BehaviorRelay<[NotificationsData]?> {
        let apiResponse: BehaviorRelay<[NotificationsData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[NotificationsData], NotificationsServiceRequest>(
            service: BaseServiceRequestParam<NotificationsServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.NOTIFICATIONS_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: NotificationsServiceRequest (
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idCompania: "10",
                        numPagina: 1,
                        tamanoPagina: 40
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

    func markAsRead(with id: String) -> BehaviorRelay<NotificationsData?> {
        let apiResponse: BehaviorRelay<NotificationsData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<NotificationsData, ReadNotificationServiceRequest>(
            service: BaseServiceRequestParam<ReadNotificationServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.READ_NOTIFICATION_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: ReadNotificationServiceRequest (
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idNotificacion: id
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

