//
//  PaymentOrderResponse.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 28/9/22.
//

import Foundation

class PaymentOrderResponse: Codable {
    var idProceso: String?
    var codigoAutorizacion: String?
    var idTransaccionBac: String?
    var orderId: String?
    var url: String?
    var indRedirect: Int?
}
