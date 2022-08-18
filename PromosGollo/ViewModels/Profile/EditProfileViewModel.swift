//
//  EditProfileViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxRelay

class EditProfileViewModel {
    private let service = GolloService()
    private let firebaseService = FirebaseService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let userManager = UserManager.shared
    var docTypes: [DocType] = []
    var genderTypes: [GenderType] = []
    var data: UserData? = nil
    
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

}

