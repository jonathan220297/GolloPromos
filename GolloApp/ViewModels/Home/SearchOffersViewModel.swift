//
//  SearchOffersViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 14/10/22.
//

import Foundation
import RxRelay

class SearchOffersViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var history: [String] = []
    var products: [Product] = []

    func fetchFilteredProducts(with searchText: String? = nil) -> BehaviorRelay<[Offers]?> {
        let apiResponse: BehaviorRelay<[Offers]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[Offers], OfferFilteredListServiceRequest>(
            service: BaseServiceRequestParam<OfferFilteredListServiceRequest>(
                servicio: ServicioParam(
//                    encabezado: Encabezado(
//                        idProceso: GOLLOAPP.FILTERED_PRODUCTS_PROCESS_ID.rawValue,
//                        idDevice: getDeviceID(),
//                        idUsuario: UserManager.shared.userData?.uid ?? "",
//                        timeStamp: String(Date().timeIntervalSince1970),
//                        idCia: 10,
//                        token: getToken(),
//                        integrationId: nil
//                    ),
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.FILTERED_PRODUCTS_PROCESS_ID.rawValue),
                    parametros: OfferFilteredListServiceRequest (
                        idCategoria: nil,
                        orden: nil,
                        busqueda: searchText,
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idCompania: "10",
                        idTaxonomia: -1,
                        numPagina: 1,
                        tamanoPagina: 30
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
