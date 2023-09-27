//
//  PaymentAddressViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 22/9/22.
//

import Foundation
import RxSwift
import RxRelay

class PaymentAddressViewModel {
    private let service = GolloService()
    let userManager = UserManager.shared
    let carManager = CarManager.shared
    
    var itemsArray: [String] = []
    var documentTypeArray: [DocType] = []
    var statesArray: BehaviorRelay<[State]> = BehaviorRelay(value: [])
    var citiesArray: BehaviorRelay<[County]> = BehaviorRelay(value: [])
    var districtArray: BehaviorRelay<[District]> = BehaviorRelay(value: [])
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let firstNameSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let lastNameSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let emailSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let phoneNumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let documentTypeSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let identificationNumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let countrySubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let stateSubject: BehaviorRelay<State?> = BehaviorRelay(value: nil)
    let countySubject: BehaviorRelay<County?> = BehaviorRelay(value: nil)
    let districtSubject: BehaviorRelay<District?> = BehaviorRelay(value: nil)
    let addressSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let postalCodeSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let latitudeSubject: BehaviorRelay<Double?> = BehaviorRelay(value: nil)
    let longitudeSubject: BehaviorRelay<Double?> = BehaviorRelay(value: nil)
    
    let nameError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let lastNameError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let emailError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let phoneNumberError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let documentTypeError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let identificationNumberError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let stateError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let countyError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let districtError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let addressError: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var isValidFirstPartForm: Observable<Bool> {
        return Observable.combineLatest(firstNameSubject, lastNameSubject, emailSubject, phoneNumberSubject, documentTypeSubject) { firstName, lastName, email, phonenumber, document in
            
            guard let firstName = firstName,
                  let lastName = lastName,
                  let email = email,
                  let phonenumber = phonenumber,
                  let document = document else {
                return false
            }
            
            return !(firstName.isEmpty)
                && !(lastName.isEmpty)
                && !(email.isEmpty)
                && email.isValidEmail()
                && !(phonenumber.isEmpty)
                && !(document.isEmpty)
        }
    }
    
    var isValidSecondPartForm: Observable<Bool> {
        
        return Observable.combineLatest(identificationNumberSubject, stateSubject, countySubject, districtSubject, addressSubject) { identificationNumber, state, county, district, address in
            
            guard let identificationNumber = identificationNumber,
                  state != nil,
                  county != nil,
                  district != nil,
                  let address = address else {
                return false
            }
            
            return !(identificationNumber.isEmpty)
                && !(address.isEmpty)
        }
    }
    
    var isFormValid: Observable<Bool> {
        return Observable.combineLatest(isValidFirstPartForm, isValidSecondPartForm) { firstPart, secondPart in
            return firstPart && secondPart
        }
    }
    
    func validateInputs() -> Bool {
        var result = true
        nameError.accept(false)
        lastNameError.accept(false)
        emailError.accept(false)
        phoneNumberError.accept(false)
        documentTypeError.accept(false)
        identificationNumberError.accept(false)
        stateError.accept(false)
        countyError.accept(false)
        districtError.accept(false)
        addressError.accept(false)
        if firstNameSubject.value?.isEmpty ?? true {
            nameError.accept(true)
            result = false
        }
        if lastNameSubject.value?.isEmpty ?? true {
            lastNameError.accept(true)
            result = false
        }
        if emailSubject.value?.isEmpty ?? false {
            emailError.accept(true)
            result = false
        }
        if phoneNumberSubject.value?.isEmpty ?? false {
            phoneNumberError.accept(true)
            result = false
        }
        if documentTypeSubject.value?.isEmpty ?? false {
            documentTypeError.accept(true)
            result = false
        }
        if identificationNumberSubject.value?.isEmpty ?? true {
            identificationNumberError.accept(true)
            result = false
        }
        if stateSubject.value == nil {
            stateError.accept(true)
            result = false
        }
        if countySubject.value == nil {
            countyError.accept(true)
            result = false
        }
        if districtSubject.value == nil {
            districtError.accept(true)
            result = false
        }
        if addressSubject.value?.isEmpty ?? true {
            addressError.accept(true)
            result = false
        }
        return result
    }

    func processDocTypes() {
        documentTypeArray.append(DocType(code: "C", name: "ProfileViewController_cedula".localized))
        documentTypeArray.append(DocType(code: "J", name: "ProfileViewController_cedula_juridica".localized))
        documentTypeArray.append(DocType(code: "P", name: "ProfileViewController_passport".localized))
        documentTypeArray.append(DocType(code: "E", name: "Extranjero"))
        documentTypeArray.append(DocType(code: "R", name: "Residente"))
        documentTypeArray.append(DocType(code: "N", name: "Nite"))
    }
    
    func fetchStates() -> BehaviorRelay<[State]?> {
        let apiResponse: BehaviorRelay<[State]?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<[State], StateListRequest>(
            service: BaseServiceRequestParam<StateListRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.STATES_CITIES.rawValue),
                    parametros: StateListRequest(
                        idProvincia: "",
                        idCanton: ""
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

    func fetchCities(state: String) -> BehaviorRelay<Provincias?> {
        let apiResponse: BehaviorRelay<Provincias?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<Provincias, StateListRequest>(
            service: BaseServiceRequestParam<StateListRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.STATES_CITIES.rawValue),
                    parametros: StateListRequest(
                        idProvincia: state,
                        idCanton: ""
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
    
    func prepareAddressInfoForPayment() {
        let firstName = firstNameSubject.value
        let lastName = lastNameSubject.value
        let email = emailSubject.value
        let phoneNumber = phoneNumberSubject.value
        _ = documentTypeSubject.value
        let identificationNumber = identificationNumberSubject.value
        let state = stateSubject.value
        let county = countySubject.value
        let district = districtSubject.value
        let address = addressSubject.value
        _ = postalCodeSubject.value
        let latitude = latitudeSubject.value
        let longitude = longitudeSubject.value
        let deliveryInfo = DeliveryInfo(
            codigoFlete: carManager.shippingMethod?.cargoCode ?? "-1",
            coordenadaX: latitude ?? 0.0,
            coordenadaY: longitude ?? 0.0,
            direccion: address ?? "",
            email: email ?? "",
            fechaEntrega: "",
            firstName: firstName ?? "",
            horaEntrega: "",
            idCanton: county?.idCanton ?? "",
            idDistrito: district?.idDistrito ?? "",
            idProvincia: state?.idProvincia ?? "",
            idReceptor: identificationNumber ?? "",
            lastName: lastName ?? "",
            lugarDespacho: "",
            montoFlete: carManager.shippingMethod?.cost ?? 0.0,
            nomReceptor: (firstName ?? "") + " " + (lastName ?? ""),
            telReceptor: phoneNumber ?? "",
            tipoEntrega: "10",
            tipoIDRecep: "C"
        )
        carManager.deliveryInfo = deliveryInfo
    }
    
    func isValidAddress() -> Bool {
        guard countrySubject.value != nil,
              stateSubject.value != nil,
              countySubject.value != nil,
              let address = addressSubject.value else { return false }
        
        return !(address.isEmpty)
    }
    
    func saveAddress() -> BehaviorRelay<Bool?> {
        let apiResponse: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(BaseRequest<Bool?, SaveUserAddressRequest>(
            service: BaseServiceRequestParam<SaveUserAddressRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.SAVE_ADDRESS.rawValue),
                    parametros: SaveUserAddressRequest(
                        idCliente: Variables.userProfile?.idCliente ?? "",
                        idProvincia: stateSubject.value?.idProvincia ?? "",
                        idCanton: countySubject.value?.idCanton ?? "",
                        idDistrito: districtSubject.value?.idDistrito ?? "",
                        direccionExacta: addressSubject.value ?? "",
                        codigoPostal: postalCodeSubject.value ?? "",
                        GPS_X: 0.0,
                        GPS_Y: 0.0
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
