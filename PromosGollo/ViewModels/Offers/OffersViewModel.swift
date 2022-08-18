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
    var offers: [ProductsData] = []
    var offersFilteres: [ProductsData] = []
    
    var categoryOffers: [CategoryOffers] = []
    var filterSelected = false
    var idCategory: String? = nil
    var idStore: String? = nil
    var reloadTableViewData: (()->())?
    
    var offersQuery: [ProductsData] = []
    var offersQueryFiltered: [ProductsData] = []

    func fetchCategories() -> BehaviorRelay<[CategoriesData]?> {
        let apiResponse: BehaviorRelay<[CategoriesData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[CategoriesData], CategoriesServiceRequest>(
            service: BaseServiceRequestParam<CategoriesServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.OFFER_CATEGORIES_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil),
                    parametros: CategoriesServiceRequest (
                        idCliente: UserManager.shared.userData?.uid ?? "",
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

    func fetchOffers(with category: String? = nil) -> BehaviorRelay<[ProductsData]?> {
        let apiResponse: BehaviorRelay<[ProductsData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[ProductsData], OffersServiceRequest>(
            service: BaseServiceRequestParam<OffersServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.OFFER_CAT_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: OffersServiceRequest (
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idCompania: "10",
                        idCategoria: category
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
    
    func fetchQueryOffers(with query: String? = nil,
                          _ idStore: String? = nil,
                          _ idCategory: String? = nil) -> BehaviorRelay<[ProductsData]?> {
        let apiResponse: BehaviorRelay<[ProductsData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[ProductsData], ProductServiceRequest>(
            service: BaseServiceRequestParam<ProductServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.OFFER_LIST_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil),
                    parametros: ProductServiceRequest(
                        idCliente: "",
                        idCompania: "10",
                        idCategoria: idCategory,
                        idTienda: idStore,
                        busqueda: query,
                        numPagina: 1,
                        tamanoPagina: 20
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
    
    func fetchOffersStores(with idStore: String) -> BehaviorRelay<[ProductsData]?> {
        let apiResponse: BehaviorRelay<[ProductsData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[ProductsData], ProductServiceRequest>(
            service: BaseServiceRequestParam<ProductServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.OFFER_LIST_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil),
                    parametros: ProductServiceRequest(
                        idCliente: UserManager.shared.userData?.uid ?? "",
                        idCompania: "10",
                        idTienda: idStore,
                        numPagina: 1,
                        tamanoPagina: 10
                    )
                )
            )
        )) { (response) in
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
    
    func processCategoryOrders(completion: @escaping(_ result: Bool) -> ()) {
        var categoriesOffers: [CategoryOffers] = []
        for category in categories {
            let offersCat = offers.filter { (o) -> Bool in
                o.tipoPromoApp == category.idTipoCategoriaApp
            }
            if offersCat.count > 0 {
                var offers: [ProductsData] = []
                if offersCat.count > 4 {
                    offers = Array(offersCat[0..<4])
                } else {
                    offers = offersCat
                }
                let columns = round(Double(offers.count / 2))
                categoriesOffers.append(CategoryOffers(category: category,
                                                       offers: offers,
                                                       height: Int((columns * 350.0))))
            }
        }
        self.categoryOffers = categoriesOffers
        completion(true)
    }
}
