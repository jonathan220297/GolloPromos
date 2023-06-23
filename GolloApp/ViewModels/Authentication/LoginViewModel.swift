//
//  LoginViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import RxRelay
import FirebaseAuth

class LoginViewModel: NSObject {
    private let service = GolloService()
    private let userManager = UserManager.shared
    private let authService = AuthenticationService()

    var errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var hideLoading: (()->())?

    func isEmailValid(with email: String) -> Bool {
        return email.isValidEmail()
    }

    func setUserData(with data: User) {
        userManager.userData = data
    }

    func signIn(with email: String, password: String, completion: @escaping(_ user: User?, _ error: String?) -> ()) {
        authService.signIn(with: email, password) { user, error in
            if let error = error {
                self.hideLoading?()
                completion(nil, error)
                return
            }
            guard let user = user else { return }
            if user.isEmailVerified {
                completion(user, nil)
            } else {
                self.hideLoading?()
                completion(user, "Verify your email address")
            }
        }
    }
    
    func signIn(with credential: AuthCredential, completion: @escaping(_ user: User?, _ error: String?) -> Void) {
        authService.signIn(with: credential) { user, error in
            if let error = error {
                self.hideLoading?()
                completion(nil, error)
                return
            }
            guard let user = user else { return }
            completion(user, nil)
        }
    }

    func fetchUserInfo(for loginType: LoginType, idToken: String) -> BehaviorRelay<LoginData?> {
        let idDevice: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let apiResponse: BehaviorRelay<LoginData?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(
            LoginRequest(
                service: BaseServiceRequestParam<LoginServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: Encabezado(
                            idProceso: GOLLOAPP.LOGIN_PROCESS_ID.rawValue,
                            idDevice: "ee404a014d9d1e3e",
                            idUsuario: UserManager.shared.userData?.uid ?? "",
                            timeStamp: String(Date().timeIntervalSince1970),
                            idCia: 10,
                            token: idToken,
                            integrationId: nil
                        ),
//                        encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.LOGIN_PROCESS_ID.rawValue),
                        parametros: LoginServiceRequest(
                            idCliente: userManager.userData?.uid ?? "",
                            nombre: userManager.userData?.displayName ?? "",
                            apellido1: userManager.userData?.displayName ?? "",
                            apellido2: userManager.userData?.displayName ?? "",
                            tipoLogin: String(loginType.rawValue),
                            idDevice: "ee404a014d9d1e3e",
                            idDeviceToken: UIDevice.current.identifierForVendor?.uuidString ?? "",
                            sisOperativo: "iOS",
                            idEmpresa: 10
                        )
                    )
                )
            )
        ) { response in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let response):
                        if let token = response.token {
                            let _ = self.saveToken(with: token)
                        }
                        apiResponse.accept(response)
                    case .failure(let error):
                        self.errorMessage.accept(error.localizedDescription)
                    }
                }
            }
        return apiResponse
    }

    func registerDeviceToken(with deviceToken: String) -> BehaviorRelay<DeviceTokenResponse?> {
        var token: String? = nil
        let idClient: String? = UserManager.shared.userData?.uid != nil ? UserManager.shared.userData?.uid : nil
        let idDevice: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
        if !getToken().isEmpty {
            token = getToken()
        }
        let apiResponse: BehaviorRelay<DeviceTokenResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<DeviceTokenResponse?, DeviceTokenServiceRequest>(
            resource: "Procesos",
            service: BaseServiceRequestParam<DeviceTokenServiceRequest>(
                servicio: ServicioParam(
//                    encabezado: Encabezado(
//                        idProceso: GOLLOAPP.DEVICE_TOKEN_PROCESS_ID.rawValue,
//                        idDevice: getDeviceID(),
//                        idUsuario: UserManager.shared.userData?.uid ?? "",
//                        timeStamp: String(Date().timeIntervalSince1970),
//                        idCia: 10,
//                        token: token ?? "",
//                        integrationId: nil),
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.DEVICE_TOKEN_PROCESS_ID.rawValue),
                    parametros: DeviceTokenServiceRequest(
                        deleteAction: "N",
                        idCliente: idClient,
                        idDevice: idDevice,
                        idDeviceToken: deviceToken,
                        idSistemaOperativo: "IOS"
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
