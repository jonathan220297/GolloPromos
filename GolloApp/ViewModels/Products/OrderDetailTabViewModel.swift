//
//  OrderDetailTabViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import Foundation
import RxRelay

class OrderDetailTabViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")

    var royalties: [OrderDetailInformation] = []
    var products: [OrderDetailInformation] = []
    var fromNotification = false

    func fetchOrderDetail(orderId: String) -> BehaviorRelay<OrderDetailData?> {
        let apiResponse: BehaviorRelay<OrderDetailData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<OrderDetailData, OrderDetailServiceRequest>(
            service: BaseServiceRequestParam<OrderDetailServiceRequest>(
                servicio: ServicioParam(
//                    encabezado: Encabezado(
//                        idProceso: GOLLOAPP.ORDER_DETAIL_PROCESS_ID.rawValue,
//                        idDevice: getDeviceID(),
//                        idUsuario: UserManager.shared.userData?.uid ?? "",
//                        timeStamp: String(Date().timeIntervalSince1970),
//                        idCia: 10,
//                        token: getToken(),
//                        integrationId: nil
//                    ),
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.ORDER_DETAIL_PROCESS_ID.rawValue),
                    parametros: OrderDetailServiceRequest (
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idOrden: orderId
                    )
                )
            )
        )) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorMessage.accept("Ocurrió un error, inténtelo de nuevo")
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}
