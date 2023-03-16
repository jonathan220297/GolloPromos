//
//  SplashViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import FirebaseAuth
import RxRelay

class SplashViewModel: NSObject {
    private let service = GolloService()
    private let defaults = UserDefaults.standard
    private let userManager = UserManager.shared

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let updatedVersion: BehaviorRelay<String> = BehaviorRelay(value: "")
    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    
    func verifyTermsConditionsState() -> Bool {
        return defaults.bool(forKey: "termsConditionsAccepted")
    }

    func verifyUserLogged() -> Bool {
        if let user = Auth.auth().currentUser {
            setUserData(with: user)
            return true
        } else {
            return false
        }
    }

    func setUserData(with data: User) {
        userManager.userData = data
    }

    func sessionExpired() -> Bool {
        let jwt = getToken()
        // get the payload part of it
        var payload64 = jwt.components(separatedBy: ".")[1]

        // need to pad the string with = to make it divisible by 4,
        // otherwise Data won't be able to decode it
        while payload64.count % 4 != 0 {
            payload64 += "="
        }

        print("base64 encoded payload: \(payload64)")
        let payloadData = Data(base64Encoded: payload64,
                               options:.ignoreUnknownCharacters)!
        let payload = String(data: payloadData, encoding: .utf8)!
        print(payload)

        let json = try! JSONSerialization.jsonObject(with: payloadData, options: []) as! [String:Any]
        let exp = json["exp"] as! Int
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        if expDate.compare(Date()) == .orderedDescending {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                debugPrint("Logout error \(signOutError)")
            }
        }
        return expDate.compare(Date()) == .orderedDescending
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
                        token: token,
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
                        } else if code == -1 {
                            self.updatedVersion.accept(error.localizedDescription.replace(string: "[VER] ", replacement: ""))
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                    }
                }
            }
        }
        return apiResponse
    }

    func registerDeviceToken(with deviceToken: String) -> BehaviorRelay<DeviceTokenResponse?> {
        var token: String? = nil
        let idClient: String? = UserManager.shared.userData?.uid != nil ? UserManager.shared.userData?.uid : nil
        if !getToken().isEmpty {
            token = getToken()
        }
        let apiResponse: BehaviorRelay<DeviceTokenResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<DeviceTokenResponse?, DeviceTokenServiceRequest>(
            resource: "Procesos",
            service: BaseServiceRequestParam<DeviceTokenServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.DEVICE_TOKEN_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: token ?? "",
                        integrationId: nil),
                    parametros: DeviceTokenServiceRequest(
                        deleteAction: "N",
                        idCliente: idClient,
                        idDevice: "\(UUID())",
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
