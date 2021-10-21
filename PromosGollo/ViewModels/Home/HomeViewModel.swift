//
//  HomeViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation
import RxRelay

class HomeViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var sectionsArray: [HomeSection] = []

    var reloadTableViewData: (()->())?

    func getHomeConfiguration() -> BehaviorRelay<HomeConfiguration?> {
        let apiResponse: BehaviorRelay<HomeConfiguration?> = BehaviorRelay(value: nil)
        service.callWebService(HomeConfigurationRequest(
            service: BaseServiceRequest(
                servicio: Servicio(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.HOME_PROCESS_ID.rawValue,
                        idDevice: "",
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: "",
                        integrationId: nil)
                )
            )
        )) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorMessage.accept(error.localizedDescription)
                }
            }
        }
        return apiResponse
    }

    func configure(with configuration: HomeConfiguration) {
        sectionsArray.removeAll()
        guard let banners = configuration.banners,
              let sections = configuration.sections else { return }
        for banner in banners {
            sectionsArray.append(HomeSection(name: banner.name ?? "", position: banner.position ?? 0, banner: banner))
        }
        for section in sections {
            if section.linkType != nil {
                sectionsArray.append(HomeSection(name: section.name ?? "", position: section.position ?? 0, section: section))
            }
        }
        self.reloadTableViewData?()
    }
}

