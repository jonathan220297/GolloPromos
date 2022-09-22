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
//    private let service = ShoppiService()
    let userManager = UserManager.shared
//    let paymentManager = PaymentManager.shared
    
    var itemsArray: [String] = []
    var documentTypeArray: [String] = ["DUI", "Passport"]
//    var countryArray: [Country] = []
//    var statesArray: BehaviorRelay<[StatesReponse]> = BehaviorRelay(value: [])
//    var citiesArray: BehaviorRelay<[CityResponse]> = BehaviorRelay(value: [])
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let firstNameSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let lastNameSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let emailSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let phoneNumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let documentTypeSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let identificationNumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let countrySubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let stateSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let citySubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let addressSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let postalCodeSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let latitudeSubject: BehaviorRelay<Double?> = BehaviorRelay(value: nil)
    let longitudeSubject: BehaviorRelay<Double?> = BehaviorRelay(value: nil)
//    let paymentAddressSubject: BehaviorRelay<PaymentAddress?> = BehaviorRelay(value: nil)
    
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
        return Observable.combineLatest(identificationNumberSubject, countrySubject, stateSubject, citySubject, addressSubject) { identificationNumber, country, state, city, address in
            
            guard let identificationNumber = identificationNumber,
                  let country = country,
                  let state = state,
                  let city = city,
                  let address = address else {
                return false
            }
            
            return !(identificationNumber.isEmpty)
                && !(country.isEmpty)
                && !(state.isEmpty)
                && !(city.isEmpty)
                && !(address.isEmpty)
        }
    }
    
    var isFormValid: Observable<Bool> {
        return Observable.combineLatest(isValidFirstPartForm, isValidSecondPartForm) { firstPart, secondPart in
            return firstPart && secondPart
        }
    }
    
//    func configureCountryArray() {
//        countryArray.append(Country(name: "El Salvador", code: "SV"))
//    }
    
//    func fetchStates(for country: String) -> BehaviorRelay<[StatesReponse]> {
//        service.callWebService(StatesRequest(
//            country: country
//        )) { (response) in
//            switch response {
//            case .success(let data):
//                self.statesArray.accept(data)
//            case .failure(let error):
//                log.debug("Error: \(error.localizedDescription)")
//                self.errorMessage.accept(error.localizedDescription)
//            }
//        }
//        return statesArray
//    }
//
//    func fetchCities(with country: String, state: String) -> BehaviorRelay<[CityResponse]> {
//        service.callWebService(CityRequest(
//            country: country,
//            state: state
//        )) { (response) in
//            switch response {
//            case .success(let data):
//                self.citiesArray.accept(data)
//            case .failure(let error):
//                log.debug("Error: \(error.localizedDescription)")
//                self.errorMessage.accept(error.localizedDescription)
//            }
//        }
//        return citiesArray
//    }
    
//    func prepareAddressInfoForPayment() {
//        let firstName = firstNameSubject.value
//        let lastName = lastNameSubject.value
//        let email = emailSubject.value
//        let phoneNumber = phoneNumberSubject.value
//        let documentType = documentTypeSubject.value
//        let identificationNumber = identificationNumberSubject.value
//        let country = countrySubject.value
//        let state = stateSubject.value
//        let city = citySubject.value
//        let address = addressSubject.value
//        let postalCode = postalCodeSubject.value
//        let latitude = latitudeSubject.value
//        let longitude = longitudeSubject.value
//        let paymentAddress = PaymentAddress(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, documentType: documentType, identificationNumber: identificationNumber, country: country, state: state, city: city, address: address, postalCode: postalCode, latitude: latitude, longitude: longitude, items: itemsArray)
//        paymentAddressSubject.accept(paymentAddress)
//    }
    
//    func setPaymentAddressToManager() {
//        paymentManager.paymentAddress = paymentAddressSubject.value
//    }
    
    func isValidAddress() -> Bool {
        guard let country = countrySubject.value,
              let state = stateSubject.value,
              let city = citySubject.value,
              let address = addressSubject.value else { return false }
        
        return !(country.isEmpty)
            && !(state.isEmpty)
            && !(city.isEmpty)
            && !(address.isEmpty)
    }
    
//    func saveAddress() -> BehaviorRelay<Bool> {
//        let apiResponse: BehaviorRelay<Bool> = BehaviorRelay(value: false)
//        let userId = getUserId()
//        service.callWebService(AddAddressRequest(
//            userId: userId ?? "",
//            country: countrySubject.value ?? "",
//            state: stateSubject.value ?? "",
//            city: citySubject.value ?? "",
//            address: addressSubject.value ?? "",
//            postalCode: postalCodeSubject.value ?? "",
//            latitude: latitudeSubject.value ?? 0.0,
//            longitude: longitudeSubject.value ?? 0.0
//        )) { response in
//            switch response {
//            case .success(_):
//                apiResponse.accept(true)
//            case .failure(let error):
//                self.errorMessage.accept(error.localizedDescription)
//                apiResponse.accept(false)
//            }
//        }
//
//        return apiResponse
//    }
}
