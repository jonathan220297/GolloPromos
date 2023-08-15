//
//  EmmaTermsListViewModel.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 6/3/23.
//

import Foundation
import RxRelay
import FirebaseAnalytics

class EmmaTermsListViewModel {
    private let service = GolloService()
    let carManager = CarManager.shared
    
    var subTotal = 0.0
    var shipping = 0.0
    var bonus = 0.0
    var totalIntents = 0
    var validationEmail: String?
    var validationPin: String?
    var termSelected: EmmaTerms?
    
    var terms: [EmmaTerms] = []
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
    func fetchEmmaTerms() -> BehaviorRelay<EmmaTermsResponse?> {
        let apiResponse: BehaviorRelay<EmmaTermsResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<EmmaTermsResponse, EmmaTermsServiceRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<EmmaTermsServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.EMMA_TERMS_PROCESS_ID.rawValue
                        ),
                        parametros: EmmaTermsServiceRequest(
                            monto: getSubtotalAmount(),
                            numIdentificacion: Variables.userProfile?.numeroIdentificacion ?? ""
                        )
                    )
                )
            )
        ) { response in
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
    
    func sendOrder() -> BehaviorRelay<PaymentOrderResponse?> {
        guard let deliveryInfo = carManager.deliveryInfo,
              let clientID = Variables.userProfile?.numeroIdentificacion else {
            return BehaviorRelay<PaymentOrderResponse?>(value: nil)
        }
        for item in carManager.car {
            if let montoBonoProveedor = item.montoBonoProveedor, montoBonoProveedor > 0.0 {
                carManager.paymentMethod.append(
                    PaymentMethod(
                        codAutorizacion: "",
                        fechaExp: "",
                        idFormaPago: "90",
                        skuRelacionado: item.sku,
                        montoPago: (item.montoBonoProveedor ?? 0.0) * Double(item.cantidad),
                        noLineaRelacionada: 0,
                        nomTarjeta: "",
                        numTarjeta: "",
                        tipoPlazoTarjeta: "",
                        tipoTarjeta: "",
                        totalCuotas: 0,
                        indTarjeta: 0,
                        indPrincipal: 0,
                        indEmma: 1,
                        pinValidacionEmma: Int(validationPin ?? "0"),
                        plazoCredito: termSelected?.cantidadMeses ?? 0
                    )
                )
            }
        }
        carManager.paymentMethod.append(
            PaymentMethod(
                codAutorizacion: "",
                fechaExp: "",
                idFormaPago: "51",
                skuRelacionado: nil,
                montoPago: carManager.total + shipping,
                noLineaRelacionada: 0,
                nomTarjeta: "",
                numTarjeta: "",
                tipoPlazoTarjeta: "",
                tipoTarjeta: "",
                totalCuotas: 0,
                indTarjeta: 0,
                indPrincipal: 1,
                indEmma: 1,
                pinValidacionEmma: Int(validationPin ?? "0"),
                plazoCredito: termSelected?.cantidadMeses ?? 0
            )
        )
        let orderItemsDetail = orderDetail()
        let apiResponse: BehaviorRelay<PaymentOrderResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<PaymentOrderResponse?, OrderData>(
                resource: "Transacciones",
                service: BaseServiceRequestParam<OrderData>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.PRODUCT_PAYMENT.rawValue
                        ),
                        parametros: OrderData(
                            detalle: orderItemsDetail,
                            formaPago: carManager.paymentMethod,
                            idCliente: clientID,
                            infoEntrega: deliveryInfo
                        )
                    )
                )
            )
        ) { response in
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
    
    func getSubtotalAmount() -> Double {
        let products = carManager.carProductsDetail
        let amount = products.map { ($0.precioUnitario - $0.montoDescuento - ($0.montoBonoProveedor ?? 0.0)) * Double($0.cantidad) }.reduce(0, +)
        let plus = products.map { $0.montoExtragar * Double($0.cantidad) }.reduce(0, +)
        var taxes = 0.0
        products.forEach { cp in
            guard let id = cp.idCarItem else { return }
            let expenses = CoreDataService().fetchCarExpense(with: id)
            taxes += expenses.map { ($0.monto ?? 0.0) * Double(cp.cantidad) }.reduce(0, +)
        }
        return amount + plus + taxes
    }
    
    private func orderDetail() -> [OrderItem] {
        var orderItems: [OrderItem] = []
        //OrderItem
        var i = 1
        for item in carManager.car {
            let discountAmount = Double(item.cantidad) * (item.montoDescuento)
            let extendedPrice = Double(item.cantidad) * (item.precioUnitario)
            var code: String?
            var description: String?
            if let regalia = item.codRegalia, !regalia.isEmpty {
                code = regalia
            }
            if let regaliaDescripcion = item.descRegalia, !regaliaDescripcion.isEmpty {
                description = regaliaDescripcion
            }
            let extended = (extendedPrice - discountAmount)
            let extendedFormattedPrice = extended.round(to: 2)
            orderItems.append(
                OrderItem(
                    cantidad: item.cantidad,
                    mesesExtragar: item.mesesExtragar,
                    idLinea: i,
                    descripcion: item.descripcion,
                    descuento: Int(discountAmount),
                    montoDescuento: 0.0,
                    montoExtragar: item.montoExtragar.round(to: 2),
                    porcDescuento: item.porcDescuento,
                    precioExtendido: extendedFormattedPrice.round(to: 2),
                    precioUnitario: item.precioUnitario.round(to: 2),
                    sku: item.sku,
                    tipoSku: 1,
                    montoBonoProveedor: nil,
                    codRegalia: code,
                    descRegalia: description
                )
            )
            i += 1
        }
        for productTaxes in carManager.carProductsDetail {
            if let id = productTaxes.idCarItem {
                let expenses = CoreDataService().fetchCarExpense(with: id)
                for taxes in expenses {
                    orderItems.append(
                        OrderItem(
                            cantidad: productTaxes.cantidad,
                            mesesExtragar: 0,
                            idLinea: i,
                            descripcion: taxes.descripcion ?? "",
                            descuento: 0,
                            montoDescuento: 0.0,
                            montoExtragar: 0.0,
                            porcDescuento: 0.0,
                            precioExtendido: Double(productTaxes.cantidad) * (taxes.monto ?? 0.0).round(to: 2),
                            precioUnitario: (taxes.monto ?? 0.0).round(to: 2),
                            sku: taxes.skuGasto ?? "",
                            tipoSku: 1,
                            montoBonoProveedor: nil,
                            codRegalia: nil,
                            descRegalia: nil
                        )
                    )
                    i += 1
                }
            }
        }
        return orderItems
    }
    
    func addPurchaseEvent(orderNumber: String) {
        let date = Date()
        let format = date.getFormattedDate(format: "dd-MM-yyyy HH:mm:ss")
        
        Analytics.logEvent("purchase", parameters: [
            "affiliation": "App de clientes",
            "coupon": "Orden de compra",
            "currency": "CRC",
            "end_date": format,
            "item_id": "Producto",
            "items": getAnalyticsItem(),
            "shipping": carManager.shippingMethod?.shippingType ?? "",
            "start_date": format,
            "transaction_id": orderNumber,
            "value": carManager.paymentMethod.first?.montoPago ?? 0.0
        ])
    }
    
    private func getAnalyticsItem() -> [String : String] {
        var items = [String : String]()
        carManager.car.forEach { orderItem in
            items["item_id"] = orderItem.sku
            items["item_name"] = orderItem.descripcion
        }
        return items
    }
    
    func addToCartEvent() {
        Analytics.logEvent("add_to_cart", parameters: [
            "currency": "CRC",
            "items": getAnalyticsItem(),
            "value": carManager.paymentMethod.first?.montoPago ?? 0.0
        ])
    }
    
    func addPaymentInfoEvent(coupon: String) {
        Analytics.logEvent("add_payment_info", parameters: [
            "coupon": coupon,
            "currency": "CRC",
            "items": getAnalyticsItem(),
            "value": carManager.paymentMethod.first?.montoPago ?? 0.0,
            "payment_type": carManager.paymentMethod.first?.idFormaPago ?? ""
        ])
    }
    
}
