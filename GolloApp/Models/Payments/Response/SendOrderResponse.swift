//
//  SendOrderResponse.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 18/10/22.
//

import Foundation

// MARK: - SendOrderResponse
struct SendOrderResponse: Codable {
    let orderID, idProceso, codigoAutorizacion, idTransaccionBac: String?

    enum CodingKeys: String, CodingKey {
        case orderID = "orderId"
        case idProceso, codigoAutorizacion, idTransaccionBac
    }
}
