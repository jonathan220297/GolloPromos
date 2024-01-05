//
//  PaymentResponse.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 29/8/22.
//

import Foundation

struct PaymentResponse: Codable {
    var idProceso: String?
    var codigoAutorizacion: String?
    var idTransaccionBac: String?
    var orderId: String?
    var url: String?
    var indRedirect: Int?
}
