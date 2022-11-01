//
//  AccountsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 20/9/21.
//

import Foundation
import RxRelay

class OffersListViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var offers: [Offers] = []

    var reloadTableViewData: (()->())?

    func fetchOffersList(category: String, store: String?, page: Int, query: String?) -> BehaviorRelay<[Offers]?> {
        let apiResponse: BehaviorRelay<[Offers]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(OffersListRequest(service: BaseServiceRequestParam<OffersListServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.OFFER_CAT_PROCESS_ID.rawValue,
                    idDevice: getDeviceID(),
                    idUsuario: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: getToken(),
                    integrationId: nil),
                parametros: OffersListServiceRequest (
                    idCliente: "IPHNkG8EWMg2oVYOASnlMuHXHHL2",
                    idCompania: "10",
                    idCategoria: category,
                    idTienda: store,
                    busqueda: query,
                    numPagina: page,
                    tamanoPagina: 10
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
