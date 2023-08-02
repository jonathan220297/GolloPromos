//
//  SideMenuViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import RxRelay
import FirebaseAuth

class SideMenuViewModel {
    private let service = GolloService()
    let userManager = UserManager.shared

    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")

    func fetchUnreadNotifications() -> BehaviorRelay<UnreadNotificationData?> {
        let idClient: String? = UserManager.shared.userData?.uid != nil ? UserManager.shared.userData?.uid : Auth.auth().currentUser?.uid
        let apiResponse: BehaviorRelay<UnreadNotificationData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<UnreadNotificationData, UnreadNotificationServiceRequest>(
            service: BaseServiceRequestParam<UnreadNotificationServiceRequest>(
                servicio: ServicioParam(
//                    encabezado: Encabezado(
//                        idProceso: GOLLOAPP.UNREAD_NOTIFICATIONS_PROCESS_ID.rawValue,
//                        idDevice: getDeviceID(),
//                        idUsuario: idClient,
//                        timeStamp: String(Date().timeIntervalSince1970),
//                        idCia: 10,
//                        token: getToken(),
//                        integrationId: nil
//                    ),
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.UNREAD_NOTIFICATIONS_PROCESS_ID.rawValue),
                    parametros: UnreadNotificationServiceRequest (
                        idCliente: idClient ?? ""
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
                    switch error {
                    case .decoding: break;
                    case .server(code: let code, message: _):
                        if code == 401 {
                            self.errorExpiredToken.accept(true)
                            self.errorMessage.accept("")
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                    }
                }
            }
        }
        return apiResponse
    }
    
    func registerDevice(with deviceToken: String) -> BehaviorRelay<LoginData?> {
        var token: String? = nil
        let idClient: String? = UserManager.shared.userData?.uid != nil ? UserManager.shared.userData?.uid : Auth.auth().currentUser?.uid
        let idDevice: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
        if !getToken().isEmpty {
            token = getToken()
        }
        let apiResponse: BehaviorRelay<LoginData?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<LoginData?, RegisterDeviceServiceRequest>(
            resource: "Procesos/RegistroDispositivos",
            service: BaseServiceRequestParam<RegisterDeviceServiceRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.REGISTER_DEVICE_PROCESS_ID.rawValue),
                    parametros: RegisterDeviceServiceRequest(
                        idEmpresa: 10,
                        idDeviceToken: deviceToken,
                        token: token,
                        idCliente: idClient,
                        idDevice: idDevice,
                        version: Variables().VERSION_CODE,
                        sisOperativo: "IOS"
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
                    switch error {
                    case .decoding: break;
                    case .server(code: let code, message: _):
                        if code == 401 {
                            self.errorExpiredToken.accept(true)
                            self.errorMessage.accept("")
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                    }
                }
            }
        }
        return apiResponse
    }
    
    func saveToken(with token: String) -> Bool {
        if let data = token.data(using: .utf8) {
            let status = KeychainManager.save(key: "token", data: data)
            log.debug("Status: \(status)")
            return true
        } else {
            return false
        }
    }
}

