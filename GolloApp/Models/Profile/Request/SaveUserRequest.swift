//
//  SaveUserDataRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/8/22.
//

import Foundation

struct SaveUserRequest: APIRequest {

    public typealias Response = SaveUserResponse

    public var resourceName: String {
        return "Procesos"
    }

    let service: BaseServiceRequestParam<UserInfo>?

    public var dictionary: [String: Any] { return service.map { $0.dict }!! }

}
