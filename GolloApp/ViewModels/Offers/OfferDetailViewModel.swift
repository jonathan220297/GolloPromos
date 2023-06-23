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
    private let defaults = UserDefaults.standard
    
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var offerDetail: OfferDetail?
    var cartDetail: OfferCartDetail?
    var documents: [Warranty] = []
    var products: [Product] = []
    var images: [ArticleImages] = []

    func fetchOfferDetail(sku: String, centro: String = "144", bodega: String = "1") -> BehaviorRelay<OfferDetail?> {
        let apiResponse: BehaviorRelay<OfferDetail?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(OfferDetailRequest(service: BaseServiceRequestParam<OfferDetailServiceRequest>(
            servicio: ServicioParam(
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.OFFER_DETAIL_PROCESS_ID.rawValue),
                parametros: OfferDetailServiceRequest (
                    centro: centro,
                    sku: sku,
                    bodega: bodega
                )
            )
        ))) { response in
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
                    self.errorMessage.accept(error.localizedDescription)
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
    
    func setCarManagerTypeToUserDefaults(with type: String) {
        defaults.setValue(type, forKey: "carManagetTypeStarted")
    }

    func verifyCarManagerTypeState() -> String? {
        return defaults.string(forKey: "carManagetTypeStarted")
    }
    
    func deleteCarManagerTypeState() {
        defaults.removeObject(forKey: "carManagetTypeStarted")
    }

}
