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

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let userManager = UserManager.shared
    var docTypes: [DocType] = []
    var genderTypes: [GenderType] = []
    var data: UserData? = nil

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
        return Observable.combineLatest(phonenumberSubject,
                                        mobileNumberSubject,
                                        emailSubject,
                                        addressSubject) { phoneNumber, mobileNumber, email, address in

            guard let phoneNumber = phoneNumber,
                  let mobileNumber = mobileNumber,
                  let email = email,
                  let address = address else {
                return false
            }

            return !(phoneNumber.isEmpty)
            && !(mobileNumber.isEmpty)
            && !(email.isEmpty)
            && email.isValidEmail()
            && !(address.isEmpty)
        }
    }

    var isValidNewForm: Observable<Bool> {
        return Observable.combineLatest(nameSubject,
                                        lastnameSubject,
                                        birthDateSubject,
                                        genderSubject,
                                        phonenumberSubject,
                                        mobileNumberSubject,
                                        emailSubject,
                                        addressSubject) { name, lastname, birthDate, gender, phoneNumber, mobileNumber, email, address in

            guard let name = name,
                  let lastname = lastname,
                  let birthDate = birthDate,
                  let gender = gender,
                  let phoneNumber = phoneNumber,
                  let mobileNumber = mobileNumber,
                  let email = email,
                  let address = address else {
                return false
            }

            return !(name.isEmpty)
            && !(lastname.isEmpty)
            && !(birthDate.isEmpty)
            && !(gender.isEmpty)
            && !(phoneNumber.isEmpty)
            && !(mobileNumber.isEmpty)
            && !(email.isEmpty)
            && email.isValidEmail()
            && !(address.isEmpty)
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

    func fetchUserData(id: String, type: String) -> BehaviorRelay<UserData?> {
        let apiResponse: BehaviorRelay<UserData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<UserData, UserServiceRequest>(
            service: BaseServiceRequestParam<UserServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.IS_GOLLO_CUSTOMER_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: UserServiceRequest (
                        noCia: "10",
                        numeroIdentificacion: id,
                        tipoIdentificacion: type
                    )
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

    func convertImageToBase64String (img: UIImage?) -> String {
        if let image = img {
            return image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
        } else {
            return ""
        }
    }

}

