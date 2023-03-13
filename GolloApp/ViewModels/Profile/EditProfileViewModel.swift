//
//  EditProfileViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxRelay
import RxSwift

class EditProfileViewModel {
    private let service = GolloService()
    private let firebaseService = FirebaseService()

    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let userManager = UserManager.shared
    var docTypes: [DocType] = []
    var genderTypes: [GenderType] = []
    var data: UserData? = nil
    var isUpdating = false

    let nameSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let lastnameSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let secondLastnameSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let birthDateSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let genderSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let phonenumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let mobileNumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let emailSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let addressSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    var isValidForm: Observable<Bool> {
        return Observable.combineLatest(nameSubject,
                                        lastnameSubject,
                                        birthDateSubject,
                                        genderSubject,
                                        phonenumberSubject,
                                        mobileNumberSubject,
                                        emailSubject,
                                        addressSubject) { name, lastname, birthDate, gender, phoneNumber, mobileNumber, email, address in
            if self.isUpdating {
                guard let email = email,
                      let address = address else {
                    return false
                }
                if let phoneNumber = phoneNumber,
                    !phoneNumber.isEmpty,
                    !email.isEmpty,
                    !address.isEmpty {
                    return true
                } else if let mobileNumber = mobileNumber,
                            !mobileNumber.isEmpty,
                            !email.isEmpty,
                            !address.isEmpty {
                    return true
                }
            } else {
                guard let name = name,
                      let lastname = lastname,
                      let birthDate = birthDate,
                      let gender = gender,
                      let email = email,
                      let address = address else {
                    return false
                }

                return !(name.isEmpty)
                && !(lastname.isEmpty)
                && !(birthDate.isEmpty)
                && !(gender.isEmpty)
                && ((phoneNumber != nil && !phoneNumber!.isEmpty) || (mobileNumber != nil && !mobileNumber!.isEmpty))
                && !(email.isEmpty)
                && email.isValidEmail()
                && !(address.isEmpty)
            }
            return false
        }
    }
    
    func uploadPhoto(profileImage: UIImage?, firstName: String?, lastNames: String?, birthDate: Date?) {
        firebaseService.uploadPhoto(with: userManager.userData?.uid ?? "ShoppiImage", userManager.userData?.email ?? "", profileImage: profileImage, firstName: firstName, lastNames: lastNames, birthDate: birthDate) {[weak self] error in
            if let error = error {
                self?.errorMessage.accept(error)
            }
        }
    }
    
    func processDocTypes() {
        docTypes.append(DocType(code: "C", name: "ProfileViewController_cedula".localized))
        docTypes.append(DocType(code: "J", name: "ProfileViewController_cedula_juridica".localized))
        docTypes.append(DocType(code: "P", name: "ProfileViewController_passport".localized))
        docTypes.append(DocType(code: "E", name: "Extranjero"))
        docTypes.append(DocType(code: "R", name: "Residente"))
        docTypes.append(DocType(code: "N", name: "Nite"))
    }

    func processGenderTypes() {
        genderTypes.append(GenderType(code: "M", name: "Hombre"))
        genderTypes.append(GenderType(code: "F", name: "Mujer"))
    }

    func fetchUserData(id: String, type: String, pin: Int = 0) -> BehaviorRelay<UserData?> {
        let apiResponse: BehaviorRelay<UserData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<UserData, UserServiceRequest>(
            service: BaseServiceRequestParam<UserServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.IS_GOLLO_CUSTOMER_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: UserServiceRequest (
                        noCia: "10",
                        numeroIdentificacion: id,
                        tipoIdentificacion: type,
                        indPin: pin
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

    func updateUserData(with userInfo: UserInfo) -> BehaviorRelay<SaveUserResponse?> {
        let apiResponse: BehaviorRelay<SaveUserResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<SaveUserResponse, UserInfo>(
            service: BaseServiceRequestParam<UserInfo>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.REGISTER_CLIENT_PROCESS_ID.rawValue),
                    parametros: userInfo
                )
            )
        )) { response in
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

    func deleteUserProfile() -> BehaviorRelay<LoginData?> {
        let apiResponse: BehaviorRelay<LoginData?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<LoginData?, DeleteProfileServiceRequest>(
            service: BaseServiceRequestParam<DeleteProfileServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.REMOVE_USER_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil),
                    parametros: DeleteProfileServiceRequest(
                        idEmpresa: 10,
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

    func convertImageToBase64String (img: UIImage?) -> String {
        if let image = img {
            return image.jpegData(compressionQuality: 0.25)?.base64EncodedString() ?? ""
        } else {
            return ""
        }
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

