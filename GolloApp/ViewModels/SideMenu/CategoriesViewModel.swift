//
//  CategoriesViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import Foundation
import RxRelay

class CategoriesViewModel {
    private let service = GolloService()

    func fetchCategoriesFilter() -> BehaviorRelay<[CategoriesFilterData]?> {
        let apiResponse: BehaviorRelay<[CategoriesFilterData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[CategoriesFilterData], CategoriesFilterServiceRequest>(
            service: BaseServiceRequestParam<CategoriesFilterServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.CATEGORIES_FILTER_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: CategoriesFilterServiceRequest (
                        idCompania: "10"
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
