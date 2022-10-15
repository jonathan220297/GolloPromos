//
//  PaymentConfirmViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 28/9/22.
//

import Foundation
import RxRelay

class PaymentConfirmViewModel {
    private let service = GolloService()
    
    var subTotal = 0.0
    var shipping = 0.0
    var bonus = 0.0
    var isAccountPayment = true

    func fetchPaymentMethods() -> BehaviorRelay<[PaymentMethodResponse]?> {
        let apiResponse: BehaviorRelay<[PaymentMethodResponse]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[PaymentMethodResponse], PaymentMethodServiceRequest>(
            service: BaseServiceRequestParam<PaymentMethodServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.PAYMENT_METHODS_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: PaymentMethodServiceRequest (
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
