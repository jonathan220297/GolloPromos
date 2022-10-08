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

    var products: [OrderDetailInformation] = []

    func fetchOrderDetail(orderId: String) -> BehaviorRelay<OrderDetailData?> {
        let apiResponse: BehaviorRelay<OrderDetailData?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<OrderDetailData, OrderDetailServiceRequest>(
            service: BaseServiceRequestParam<OrderDetailServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.ORDER_DETAIL_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
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
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}