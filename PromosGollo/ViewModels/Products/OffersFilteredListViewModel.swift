//
//  OffersFilteredListViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/10/22.
//

import Foundation
import RxRelay

class OffersFilteredListViewModel {
    private let service = GolloService()

    var categories: [CategoriesFilterData] = []
    var products: [Product] = []

    func fetchFilteredCategories() -> BehaviorRelay<[CategoriesFilterData]?> {
        let apiResponse: BehaviorRelay<[CategoriesFilterData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[CategoriesFilterData], CategoriesFilteredListServiceRequest>(
            service: BaseServiceRequestParam<CategoriesFilteredListServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.CATEGORIES_FILTER_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: CategoriesFilteredListServiceRequest (
                        idCategoria: "1",
                        idCompania: "10",
                        idTaxonomia: -1
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

    func fetchFilteredProducts() -> BehaviorRelay<[Product]?> {
        let apiResponse: BehaviorRelay<[Product]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[Product], OfferFilteredListServiceRequest>(
            service: BaseServiceRequestParam<OfferFilteredListServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.FILTERED_PRODUCTS_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: OfferFilteredListServiceRequest (
                        idCategoria: "1",
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
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }

}
