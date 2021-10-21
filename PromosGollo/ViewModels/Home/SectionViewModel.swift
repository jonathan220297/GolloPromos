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

    var productsArray: [ProductsData] = []
    var section: Section?

    var reloadCollectionView: (()->())?

    func configureRecentView() {
        let productsCD = DataManager.sharedInstance.retriveRecents()
        var products: [ProductsData] = []
        for product in productsCD {
            if let data = product.json.data(using: .utf8) {
                do {
                    let object = try JSONDecoder().decode(ProductsData.self, from: data)
                    products.append(object)
                } catch let error as NSError {
                    //log.debug("Error: \(error.localizedDescription)")
                }
            }
        }
        productsArray = products.evenlySpaced(length: 3)
        reloadCollectionView?()
    }

    func fetchProductsByCategory(with category: String) -> BehaviorRelay<[ProductsData]?> {
        let apiResponse: BehaviorRelay<[ProductsData]?> = BehaviorRelay(value: nil)
        service.callWebService(ProductsRequest(service: BaseServiceRequestParam<ProductServiceRequest>(
            servicio: ServicioParam(
                encabezado: Encabezado(
                    idProceso: GOLLOAPP.OFFER_LIST_PROCESS_ID.rawValue,
                    idDevice: "",
                    idUsuario: UserManager.shared.userData?.uid ?? "",
                    timeStamp: String(Date().timeIntervalSince1970),
                    idCia: 10,
                    token: "",
                    integrationId: nil),
                parametros: ProductServiceRequest(
                    idCliente: "",
                    idCompania: "10",
                    numPagina: 1,
                    tamanoPagina: 4
                )
            )
        ))) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                //log.debug("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
}
