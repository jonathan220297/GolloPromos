//
//  HomeRequest.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation

struct HomeConfigurationRequest: APIRequest {

    public typealias Response = HomeConfiguration

    public var resourceName: String {
        return "Procesos"
    }
    
    let service: BaseServiceRequest?
    
    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }
}


extension Encodable {
    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}
