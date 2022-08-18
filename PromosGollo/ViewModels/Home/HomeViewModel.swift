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
    var tableViewWidth: CGFloat = 0.0

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
                        token: getToken(),
                        integrationId: nil
                    )
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
        for i in 0..<sectionsArray.count {
            if !sectionsArray[i].isSection {
                let image = sectionsArray[i].banner?.images?.first?.image?.replacingOccurrences(of: " ", with: "%20") ?? ""
                log.debug(image)
                sectionsArray[i].banner?.uiHeight = fetchImageHeight(with: URL(string: image))
            }
        }
        self.reloadTableViewData?()
    }
    
    func fetchImageHeight(with url: URL?) -> CGFloat {
        guard let url = url else { return 0.0 }
        if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as! Double
                let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! Double
                let myViewWidth = self.tableViewWidth
     
                let ratio = myViewWidth / CGFloat(pixelWidth)
                let scaledHeight = CGFloat(pixelHeight) * ratio

                return scaledHeight
            }
        }
        return 0.0
    }
}

