//
//  SectionViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation
import RxRelay

class SectionViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    
    var productsArray: [Product] = []
    var section: Section?

    var reloadCollectionView: (()->())?

    func configureRecentView() {
        let productsCD = DataManager.sharedInstance.retriveRecents()
        var products: [Product] = []
        for product in productsCD {
            if let data = product.json.data(using: .utf8) {
                do {
                    let object = try JSONDecoder().decode(Product.self, from: data)
                    products.append(object)
                } catch _ as NSError {
                    //log.debug("Error: \(error.localizedDescription)")
                }
            }
        }
        productsArray = products.evenlySpaced(length: 3)
        reloadCollectionView?()
    }

    func fetchProductsByCategory(with category: Int) -> BehaviorRelay<[Product]?> {
        let apiResponse: BehaviorRelay<[Product]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[Product], ProductServiceRequest>(
            service: BaseServiceRequestParam<ProductServiceRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.OFFER_LIST_PROCESS_ID.rawValue),
                    parametros: ProductServiceRequest(
                        idCliente: "",
                        idCompania: "10",
                        numPagina: 1,
                        tamanoPagina: 4
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
                    switch error {
                    case .decoding: break;
                    case .server(code: let code, message: _):
                        if code == 401 {
                            self.errorExpiredToken.accept(true)
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                    }
                //log.debug("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}
