//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 20/9/21.
//

import Foundation
import RxRelay

class OffersViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var categories: [CategoriesData] = []
    var offers: [Offers] = []

    var reloadTableViewData: (()->())?

    func fetchCategories() -> BehaviorRelay<[CategoriesData]?> {
        let apiResponse: BehaviorRelay<[CategoriesData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(CategoriesRequest(service: BaseServiceRequestParam<CategoriesServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.OFFER_CATEGORIES_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: CategoriesServiceRequest (
                    idCliente: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    idCompania: "10"
                )
            )
        ))) { response in
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

    func fetchOffers() -> BehaviorRelay<[Offers]?> {
        let apiResponse: BehaviorRelay<[Offers]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(OffersRequest(service: BaseServiceRequestParam<OffersServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.OFFER_CAT_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: OffersServiceRequest (
                    idCliente: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    idCompania: "10"
                )
            )
        ))) { response in
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
