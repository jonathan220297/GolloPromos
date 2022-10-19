//
//  PaymentSuccessViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 19/10/22.
//

import Foundation

class PaymentSuccessViewModel {
    let paymentMethodSelected: PaymentMethodResponse
    var accountPaymentResponse: PaymentResponse?
    var productPaymentResponse: PaymentOrderResponse?
    
    init(paymentMethodSelected: PaymentMethodResponse, accountPaymentResponse: PaymentResponse? = nil, productPaymentResponse: PaymentOrderResponse? = nil) {
        self.paymentMethodSelected = paymentMethodSelected
        self.accountPaymentResponse = accountPaymentResponse
        self.productPaymentResponse = productPaymentResponse
    }
}
