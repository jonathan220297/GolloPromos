//
//  OrdersTabViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation
import RxRelay

class OrdersTabViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var orders: [Order] = []

    func fetchOrders() -> BehaviorRelay<OrdersData?> {
        let apiResponse: BehaviorRelay<OrdersData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<OrdersData, OrderServiceRequest>(
            service: BaseServiceRequestParam<OrderServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.ORDERS_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil),
                    parametros: OrderServiceRequest (
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
                    self.errorMessage.accept("\(error.localizedDescription)")
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}
