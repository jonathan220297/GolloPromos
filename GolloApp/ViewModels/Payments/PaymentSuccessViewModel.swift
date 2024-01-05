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
    var showScanAndGoDisclaimer: Bool = false
    var isCrediGolloPayment: Bool = false
    
    init(paymentMethodSelected: PaymentMethodResponse, accountPaymentResponse: PaymentResponse? = nil, productPaymentResponse: PaymentOrderResponse? = nil, showScanAndGoDisclaimer: Bool, isCrediGolloPayment: Bool = false) {
        self.paymentMethodSelected = paymentMethodSelected
        self.accountPaymentResponse = accountPaymentResponse
        self.productPaymentResponse = productPaymentResponse
        self.showScanAndGoDisclaimer = showScanAndGoDisclaimer
        self.isCrediGolloPayment = isCrediGolloPayment
    }
}
