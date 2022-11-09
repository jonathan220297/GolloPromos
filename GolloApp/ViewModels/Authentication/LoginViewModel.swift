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
                completion(nil, "You must verify your email address to login.")
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
        let apiResponse: BehaviorRelay<LoginData?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(
            LoginRequest(
                service: BaseServiceRequestParam<LoginServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: Encabezado(
                            idProceso: GOLLOAPP.LOGIN_PROCESS_ID.rawValue,
                            idDevice: getDeviceID(),
                            idUsuario: UserManager.shared.userData?.uid ?? "",
                            timeStamp: String(Date().timeIntervalSince1970),
                            idCia: 10,
                            token: idToken,
                            integrationId: nil),
                        parametros: LoginServiceRequest(
                            idCliente: userManager.userData?.uid ?? "",
                            nombre: userManager.userData?.displayName ?? "",
                            apellido1: userManager.userData?.displayName ?? "",
                            apellido2: userManager.userData?.displayName ?? "",
                            tipoLogin: String(loginType.rawValue),
                            idDevice: getDeviceID(),
                            idDeviceToken: "",
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
