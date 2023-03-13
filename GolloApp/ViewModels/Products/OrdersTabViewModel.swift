//
//  OrdersTabViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation
import RxRelay

class OrdersTabViewModel {
    private let service = GolloService()

    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var orders: [Order] = []

    func fetchOrders() -> BehaviorRelay<OrdersData?> {
        let apiResponse: BehaviorRelay<OrdersData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<OrdersData, OrderServiceRequest>(
            service: BaseServiceRequestParam<OrderServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.ORDERS_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil),
                    parametros: OrderServiceRequest (
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
        let idClient: String? = UserManager.shared.userData?.uid != nil ? UserManager.shared.userData?.uid : nil
        if !getToken().isEmpty {
            token = getToken()
        }
        let apiResponse: BehaviorRelay<LoginData?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<LoginData?, RegisterDeviceServiceRequest>(
            resource: "Procesos/RegistroDispositivos",
            service: BaseServiceRequestParam<RegisterDeviceServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.REGISTER_DEVICE_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: token ?? "",
                        integrationId: nil),
                    parametros: RegisterDeviceServiceRequest(
                        idEmpresa: 10,
                        idDeviceToken: deviceToken,
                        Token: token,
                        idCliente: idClient,
                        idDevice: "\(UUID())",
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
