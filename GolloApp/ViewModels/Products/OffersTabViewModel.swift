//
//  OffersTabViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 20/9/22.
//

import Foundation
import RxRelay

class OfferSection {
    init(name: String, urlImage: String, offers: [Product]) {
        self.name = name
        self.urlImage = urlImage
        self.offers = offers
    }
    
    let name: String
    let urlImage: String
    var offers: [Product]
}

class OffersTabViewModel {
    private let service = GolloService()
    
    var sections: [OfferSection] = []
    
    var categories: [CategoriesData] = []
    var offers: [Product] = []
    var offersFiltered: [Product] = []
    
    var categoryOffers: [CategoryOffers] = []
    
    init() { }
    
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

    func fetchOffers(with category: String? = nil) -> BehaviorRelay<[Product]?> {
        let apiResponse: BehaviorRelay<[Product]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[Product], OffersServiceRequest>(
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
    
    func processCategoryOrders(completion: @escaping(_ result: Bool) -> ()) {
        var categoriesOffers: [CategoryOffers] = []
        for category in categories {
            let offersCat = offers.filter { (o) -> Bool in
                o.tipoPromoApp == category.idTipoCategoriaApp
            }
            if offersCat.count > 0 {
                var offers: [Product] = []
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
    
    func processOffers(with offers: [Product]) {
        sections.removeAll()
        for i in 0..<categories.count {
            if categories[i].idTipoCategoriaApp != 0 {
                var offersToSave: [Product] = []
                for offer in offers {
                    if offer.tipoPromoApp == categories[i].idTipoCategoriaApp {
                        offersToSave.append(offer)
                    }
                }
                sections.append(
                    OfferSection(
                        name: categories[i].descripcion ?? "",
                        urlImage: categories[i].urlImagen ?? "",
                        offers: Array(offersToSave.prefix(4))
                    )
                )
            }
        }
    }
}
