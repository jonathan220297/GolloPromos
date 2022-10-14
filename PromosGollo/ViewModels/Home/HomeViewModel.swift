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
    let errorExpiredToken = BehaviorRelay<Bool?>(value: nil)
    var sectionsArray: [HomeSection] = []

    var reloadTableViewData: (()->())?
    var tableViewWidth: CGFloat = 0.0
    
    var sections: [MasterSection] = []
    var configuration: HomeConfiguration?

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
                    print("error: \(error)")
                    switch error {
                    case .decoding: break;
                    case .server(code: let code, message: _):
                        if code == 401 {
                            self.errorExpiredToken.accept(true)
                            self.errorMessage.accept("")
                        } else {
                            self.errorMessage.accept(error.localizedDescription)
                        }
                    }
                }
            }
        }
        return apiResponse
    }

    func configure(with configuration: HomeConfiguration) {
        sectionsArray.removeAll()
        guard let banners = configuration.banners,
              let sections = configuration.sections else { return }
        if !Variables.isRegisterUser {
            sectionsArray.append(HomeSection(name: "", position: 0, signUp: true))
        }
        for banner in banners {
            sectionsArray.append(HomeSection(name: banner.name ?? "", position: banner.position ?? 0, banner: banner))
        }
        for section in sections {
            // Remove section name validation
            if section.linkType != nil && !(section.name == "Promociones VIP") {
                sectionsArray.append(HomeSection(name: section.name ?? "", position: section.position ?? 0, section: section))
            }
        }
        for i in 0..<sectionsArray.count {
            if !sectionsArray[i].isSection {
                let image = sectionsArray[i].banner?.images?.first?.image?.replacingOccurrences(of: " ", with: "%20") ?? ""
                log.debug(image)
                downloaded(from: image) { height in
                    self.sectionsArray[i].banner?.uiHeight = height
                }
            }
        }
        self.reloadTableViewData?()
    }
    
    func configureSections() {
        if let banners = configuration?.banners {
            for banner in banners {
                self.sections.append(
                    MasterSection(
                        position: banner.position,
                        name: nil,
                        height: Double(banner.height ?? 0) * 0.2,
                        banner: banner,
                        product: nil
                    )
                )            }
        }
        if let configSection = configuration?.sections {
            for section in configSection {
                sections.append(
                    MasterSection(
                        position: section.position,
                        name: section.name,
                        height: 0,
                        banner: nil,
                        product: section.productos
                    )
                )
            }
        }
        self.reloadTableViewData?()
    }
    
    func downloaded(from url: URL, completion: @escaping(_ image: UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    func downloaded(from link: String, completion: @escaping(_ height: Double) -> Void) {
        guard let url = URL(string: link) else {
            completion(0.0)
            return
        }
        downloaded(from: url) { image in
            guard let height = image?.size.height,
                  let width = image?.size.width else { return }
            let myViewWidth = self.tableViewWidth
            
            let ratio = myViewWidth / CGFloat(width)
            let scaledHeight = CGFloat(height) * ratio
            completion(scaledHeight)
        }
    }
}
