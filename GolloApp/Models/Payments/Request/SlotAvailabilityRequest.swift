//
//  SlotAvailabilityRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 2/1/24.
//

import Foundation

struct SlotAvailabilityRequest: APIRequest {

    public typealias Response = SlotAvailabilityResponse

    public var resourceName: String {
        return "InstaLeap/Availability"
    }

    let service: BaseServiceRequestParam<SlotAvailabilityServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct SlotAvailabilityServiceRequest: Codable {
    var origin, destination: Destination?
    var currency_code, start, end: String?
    let slot_size, minimum_slot_size: Int?
    let operational_models_priority: [String]
    let fallback: Bool?
    let store_reference: String?
    var job_items: [JobItems]
}

struct Destination: Codable {
    let name, address, description: String?
    let latitude, longitude: Double?
}

struct JobItems: Codable {
    let quantity_found_limits: QuantityFoundLimits?
    let id, name, photo_url, unit, sub_unit: String?
    let quantity, sub_quantity: Int?
    let price: Double?
}

struct QuantityFoundLimits: Codable {
    let max, min: Int?
}
