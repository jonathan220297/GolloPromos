//
//  JobRequest.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 3/1/24.
//

import Foundation

struct JobRequest: APIRequest {

    public typealias Response = JobResponse

    public var resourceName: String {
        return "InstaLeap/CreateJob"
    }

    let service: BaseServiceRequestParam<JobServiceRequest>?

    public var dictionary: [String: Any] {
        return service.map { $0.dict }!!
    }

}

struct JobServiceRequest: Codable {
    let recipient: RecipientJob?
    let payment_info: PaymentInfoJob?
    let add_delivery_code: Bool?
    let contact_less: ContactLessJob?
    let slot_id, client_reference: String?
}

struct RecipientJob: Codable {
    let identification: IdentificationJob?
    let name, email, phone_number: String?
}

struct IdentificationJob: Codable {
    let number, type: String?
}

struct PaymentInfoJob: Codable {
    let prices: PricesJob?
    let payment: PaymentJob?
    let currency_code: String?
}

struct PricesJob: Codable {
    let subtotal: Double?
    let shipping_fee, discounts: Int?
    let taxes, order_value: Double?
}

struct PaymentJob: Codable {
    let method, id, payment_status, reference: String?
    let value: Double?
}

struct ContactLessJob: Codable {
    let comment, cash_receiver, phone_number: String?
}
