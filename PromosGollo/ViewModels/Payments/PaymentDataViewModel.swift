//
//  PaymentDataViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 18/8/22.
//

import Foundation
import RxRelay
import RxSwift

enum MovementType: String {
    case fee = "C"
    case presale = "P"
    case bill = "F"
}

class PaymentDataViewModel {
    //    private let service = ShoppiService()
    //    let paymentManager = PaymentManager.shared
    private let service = GolloService()
    private let carManager = CarManager.shared
    
    var isAccountPayment = true
    
    var paymentData: PaymentData?
    var paymentAmount = 0.0
    
    let months = [1,2,3,4,5,6,7,8,9,10,11,12]
    var years: [Int] = []
    
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    
    let cardNumberSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let expirationNumberSubject: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    let expirationYearSubject: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    let cardNameSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let cardCvvSubject: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    var isValidForm: Observable<Bool> {
        return Observable.combineLatest(cardNumberSubject,
                                        expirationNumberSubject,
                                        expirationYearSubject,
                                        cardNameSubject,
                                        cardCvvSubject) { cardNumber, expirationNumber, expirationYear, cardName, cardCvv in
            
            guard let cardNumber = cardNumber,
                  let _ = expirationNumber,
                  let _ = expirationYear,
                  let cardName = cardName,
                  let cardCvv = cardCvv else {
                return false
            }
            
            return !(cardNumber.isEmpty)
            && !(cardName.isEmpty)
            && !(cardCvv.isEmpty)
        }
    }
    
    func fillYears() {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: Date())
        years.append(year)
        let i = 1
        for _ in 1...10 {
            year += i
            years.append(year)
        }
    }
    
    func makeGolloPayment() -> BehaviorRelay<PaymentResponse?> {
        let expiryDate = String(expirationNumberSubject.value ?? 0) + "/" + String(expirationYearSubject.value ?? 0)
        let request = PaymentServiceRequest(
            integrationId: nil,
            idTienda: "014",
            tipoIdCliente: MovementType.fee.rawValue,
            identificacionCliente: paymentData?.documentId ?? "205080150",
            tipoMovimiento: "C",
            tipoDocMovimiento: "FC",
            numeroMovimiento: paymentData?.idCuenta ?? "",
            terminalId: UUID().uuidString,
            monto: paymentAmount,
            tipoPago: "TA",
            numeroTarjeta: cardNumberSubject.value ?? "",
            tipoPlazoTarjeta: "11723675",
            moneda: "CRC",
            nombreTarjetaHabiente: cardNameSubject.value ?? "",
            codigoSeguridad: cardCvvSubject.value ?? "",
            fechaVencimiento: expiryDate
        )
        
        let apiResponse: BehaviorRelay<PaymentResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<PaymentResponse, PaymentServiceRequest>(
                resource: "Transacciones",
                service: BaseServiceRequestParam<PaymentServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.CARD_PAYMENT_PROCESS_ID.rawValue),
                        parametros: request
                    )
                )
            )
        ) { response in
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
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                    }
                    //log.debug("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
    
    func setCardData() {
        guard let cardNumber = cardNumberSubject.value,
              let expiryMonth = expirationNumberSubject.value,
              let expiryYear = expirationYearSubject.value,
              let cardHolderName = cardNameSubject.value,
              let cvv = cardCvvSubject.value else { return }
        let expiryDate = String(expiryMonth) + "/" + String(expiryYear)
        carManager.paymentMethod.append(
            PaymentMethod(
               codAutorizacion: cvv,
               fechaExp: expiryDate,
               idFormaPago: "30",
               montoPago: carManager.total,
               noLineaRelacionada: 0,
               nomTarjeta: cardHolderName,
               numTarjeta: cardNumber,
               tipoPlazoTarjeta: "11723675",
               tipoTarjeta: "",
               totalCuotas: 0
           )
        )
    }
    
    func makeProductPayment() -> BehaviorRelay<PaymentOrderResponse?> {
        guard let deliveryInfo = carManager.deliveryInfo,
              let clientID = Variables.userProfile?.numeroIdentificacion else { return BehaviorRelay<PaymentOrderResponse?>(value: nil) }
        let apiResponse: BehaviorRelay<PaymentOrderResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<PaymentOrderResponse?, OrderData>(
                resource: "Procesos",
                service: BaseServiceRequestParam<OrderData>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.PRODUCT_PAYMENT.rawValue
                        ),
                        parametros: OrderData(
                            detalle: carManager.car,
                            formaPago: carManager.paymentMethod,
                            idCliente: clientID,
                            infoEntrega: deliveryInfo
                        )
                    )
                )
            )
        ) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorMessage.accept(error.localizedDescription)
                }
            }
        }
        return apiResponse
    }
    
    //    func setCardData() -> Bool {
    //        guard let cardNumber = cardNumberSubject.value,
    //              let expiryMonth = expirationNumberSubject.value,
    //              let expiryYear = expirationYearSubject.value,
    //              let cardHolderName = cardNameSubject.value,
    //              let cvv = cardCvvSubject.value else { return false }
    //        paymentManager.card = Card(cardNumber: cardNumber,
    //                                            expiryMonth: expiryMonth,
    //                                            expiryYear: expiryYear,
    //                                            cardHolderName: cardHolderName,
    //                                            cvv: cvv)
    //        return true
    //    }
    //
    //    func buildOrderRequest() {
    //        let userId = getUserId()
    //        var request: [String: Any] = [
    //            "userId": userId ?? "",
    //            "note": "",
    //            "total": paymentManager.total ?? 0.0,
    //            "subtotal": paymentManager.subTotal ?? 0.0
    //        ]
    //        var orderItems: [[String: Any]] = []
    //        for item in paymentManager.cart {
    //            var itemsDic: [String: Any] = [
    //                "productId": item.idProduct,
    //                "quantity": item.quantity,
    //                "storeId": item.storeId,
    //                "variationId": item.variationId ?? ""
    //            ]
    //            var attributesObj: [[String: Any]] = []
    //            if let attributes = item.attributes {
    //                for attribute in attributes {
    //                    let att: [String: Any] = [
    //                        "name": attribute.name ?? "",
    //                        "value": attribute.value ?? ""
    //                    ]
    //                    attributesObj.append(att)
    //                }
    //                itemsDic.updateValue(attributesObj, forKey: "attributes")
    //            }
    //            orderItems.append(itemsDic)
    //        }
    //        request.updateValue(orderItems, forKey: "orderItems")
    //        let paymentMethod: [String: Any] = [
    //            "id": paymentManager.paymentMethod?.id ?? "",
    //            "name": paymentManager.paymentMethod?.name ?? "",
    //            "description": paymentManager.paymentMethod?.description ?? ""
    //        ]
    //        request.updateValue(paymentMethod, forKey: "paymentMethod")
    //        let shippingMethod: [String: Any] = [
    //            "id": paymentManager.shippingMethod?.id ?? "",
    //            "name": paymentManager.shippingMethod?.name ?? "",
    //            "description": "",
    //            "cost": paymentManager.shippingMethod?.cost ?? 0,
    //            "minAmount": paymentManager.shippingMethod?.minAmount ?? 0
    //        ]
    //        request.updateValue(shippingMethod, forKey: "shippingMethod")
    //        let billingAddress: [String: Any] = [
    //            "firstName": paymentManager.paymentAddress?.firstName ?? "",
    //            "lastName": paymentManager.paymentAddress?.lastName ?? "",
    //            "email": paymentManager.paymentAddress?.email ?? "",
    //            "phoneNumber": paymentManager.paymentAddress?.phoneNumber ?? "",
    //            "documentType": paymentManager.paymentAddress?.documentType ?? "",
    //            "documentId": paymentManager.paymentAddress?.identificationNumber ?? "",
    //            "country": paymentManager.paymentAddress?.country ?? "",
    //            "state": paymentManager.paymentAddress?.state ?? "",
    //            "city": paymentManager.paymentAddress?.city ?? "",
    //            "address": paymentManager.paymentAddress?.address ?? "",
    //            "postalCode": paymentManager.paymentAddress?.postalCode ?? "",
    //            "latitude": paymentManager.paymentAddress?.latitude ?? 0.0,
    //            "longitude": paymentManager.paymentAddress?.longitude ?? 0.0
    //        ]
    //        request.updateValue(billingAddress, forKey: "billingAddress")
    //        request.updateValue(billingAddress, forKey: "shippingAddress")
    //        let card: [String: Any] = [
    //            "cardNumber": paymentManager.card?.cardNumber ?? "",
    //            "expiryMonth": paymentManager.card?.expiryMonth ?? 0,
    //            "expiryYear": paymentManager.card?.expiryYear ?? 0,
    //            "cardHolderName": paymentManager.card?.cardHolderName ?? "",
    //            "cvv": paymentManager.card?.cvv ?? ""
    //        ]
    //        request.updateValue(card, forKey: "card")
    //        paymentManager.request = request
    //    }
    //
    //    func createOrder() -> BehaviorRelay<CreateOrderResponse?> {
    //        let apiResponse: BehaviorRelay<CreateOrderResponse?> = BehaviorRelay(value: nil)
    //        service.callWebService(CreateOrderRequest()) { response in
    //            switch response {
    //            case .success(let data):
    //                apiResponse.accept(data)
    //            case .failure(let error):
    //                self.errorMessage.accept(error.localizedDescription)
    //                log.debug("Error: \(error.localizedDescription)")
    //            }
    //        }
    //        return apiResponse
    //    }
    //
    //    func cleanPaymentData() {
    //        paymentManager.cleanPaymentData()
    //    }
}
