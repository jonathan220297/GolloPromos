//
//  NotificationsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation
import RxRelay

class NotificationsViewModel {
    private let service = GolloService()
    let userManager = UserManager.shared

    var NotificationsArray: [NotificationsData] = []
    var errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")

    var page = 1
    var fetchingMore = false

    func fetchNotifications() -> BehaviorRelay<[NotificationsData]?> {
        let apiResponse: BehaviorRelay<[NotificationsData]?> = BehaviorRelay(value: nil)
        service.callWebService(NotificationsRequest(
            enterprise: 10,
            user: userManager.userData?.uid ?? "",
            notificationType: 1,
            page: page,
            perPage: 10,
            search: "",
            notificationId: ""
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
}

