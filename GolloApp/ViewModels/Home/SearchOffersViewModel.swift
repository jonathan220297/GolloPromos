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

    var history: [String] = []
    var products: [Product] = []

    func fetchFilteredProducts(with searchText: String? = nil) -> BehaviorRelay<[Offers]?> {
        let apiResponse: BehaviorRelay<[Offers]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[Offers], SearchOffersServiceRequest>(
            service: BaseServiceRequestParam<SearchOffersServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.SEARCH_PRODUCTS_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: SearchOffersServiceRequest (
                        busqueda: searchText,
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idCompania: "10",
                        idTaxonomia: -1,
                        numPagina: 1,
                        tamanoPagina: 40
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
