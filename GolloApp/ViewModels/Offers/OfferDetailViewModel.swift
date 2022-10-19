//
//  OfferDetailViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/9/22.
//

import Foundation
import RxRelay

class OfferDetailViewModel {
    
    private let service = GolloService()
    
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var offerDetail: OfferDetail?
    var cartDetail: OfferCartDetail?
    var documents: [Warranty] = []

    func fetchOfferDetail(sku: String) -> BehaviorRelay<OfferDetail?> {
        let apiResponse: BehaviorRelay<OfferDetail?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(OfferDetailRequest(service: BaseServiceRequestParam<OfferDetailServiceRequest>(
            servicio: ServicioParam(
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.OFFER_DETAIL_PROCESS_ID.rawValue),
                parametros: OfferDetailServiceRequest (
                    centro: "144",
                    sku: sku
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

    func addCart(parameters: [CartItemDetail]) -> BehaviorRelay<OfferCartDetail?> {
        let apiResponse: BehaviorRelay<OfferCartDetail?> = BehaviorRelay(value: nil)
        service.callWebServiceGolloAlternative(AddOfferCartRequest(service: BaseServiceRequestParam<AddOfferCartServiceRequest>(
            servicio: ServicioParam(
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.ADD_TO_CART_PROCESS_ID.rawValue),
                parametros: AddOfferCartServiceRequest (
                    detalle: parameters,
                    idCliente: UserManager.shared.userData?.uid ?? ""
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
