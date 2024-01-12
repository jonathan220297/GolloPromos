//
//  PaymentConfirmViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 28/9/22.
//

import Foundation
import RxRelay
import FirebaseAnalytics

class PaymentConfirmViewModel {
    private let service = GolloService()
    private let defaults = UserDefaults.standard
    
    let carManager = CarManager.shared
    
    var methods: [PaymentMethodResponse] = []
    var methodSelected: PaymentMethodResponse?
    
    var subTotal = 0.0
    var shipping = 0.0
    var bonus = 0.0
    var isAccountPayment = true
    var plazo: Int? = nil
    var prima: Double? = nil
    
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let errorJobMessage = BehaviorRelay<String?>(value: nil)

    func fetchPaymentMethods() -> BehaviorRelay<[PaymentMethodResponse]?> {
        var paymentForm = 0
        if carManager.payWithPreApproved {
            paymentForm = 1
        } else {
            paymentForm = 2
        }
        let apiResponse: BehaviorRelay<[PaymentMethodResponse]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[PaymentMethodResponse], PaymentMethodServiceRequest>(
            service: BaseServiceRequestParam<PaymentMethodServiceRequest>(
                servicio: ServicioParam(
                    encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.PAYMENT_METHODS_PROCESS_ID.rawValue),
                    parametros: PaymentMethodServiceRequest (
                        numIdentificacion: Variables.userProfile?.numeroIdentificacion ?? "",
                        formaPago: paymentForm
                    )
                )
            )
        )) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }

    func sendOrder(with crediGollo: Bool) -> BehaviorRelay<PaymentOrderResponse?> {
        guard let deliveryInfo = carManager.deliveryInfo,
              let clientID = Variables.userProfile?.numeroIdentificacion else {
            return BehaviorRelay<PaymentOrderResponse?>(value: nil)
        }
        var selectedPlazo: Int? = nil
        var selectedPrima: Double? = nil
        if crediGollo {
            selectedPlazo = plazo
            selectedPrima = prima
        } else {
            selectedPlazo = nil
            selectedPrima = nil
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
                       indEmma: 0,
                       pinValidacionEmma: nil,
                       plazoCredito: selectedPlazo,
                       prima: selectedPrima
                   )
                )
            }
        }
        carManager.paymentMethod.append(
            PaymentMethod(
               codAutorizacion: "",
               fechaExp: "",
               idFormaPago: methodSelected?.idFormaPago ?? "",
               skuRelacionado: nil,
               montoPago: carManager.total + shipping,
               noLineaRelacionada: 0,
               nomTarjeta: "",
               numTarjeta: "",
               tipoPlazoTarjeta: "",
               tipoTarjeta: "",
               totalCuotas: 0,
               indTarjeta: methodSelected?.indTarjeta ?? 0,
               indPrincipal: methodSelected?.indPrincipal ?? 0,
               indEmma: 0,
               pinValidacionEmma: nil,
               plazoCredito: selectedPlazo,
               prima: selectedPrima
           )
        )
        var indScan = false
        if let carManagerType = verifyCarManagerTypeState(), carManagerType == CarManagerType.SCAN_AND_GO.rawValue {
            indScan = true
        }
        var requiredInstaleap = 0
        if carManager.hasIntaleap {
            requiredInstaleap = 1
        }
        var updateDeliveryInfo = deliveryInfo
        updateDeliveryInfo.idJob = carManager.idJob
        updateDeliveryInfo.idSlot = carManager.hourSelected?.idSlot
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
                            infoEntrega: updateDeliveryInfo,
                            indScanAndGo: indScan,
                            requiereInstaleap: requiredInstaleap,
                            indInstaleap: carManager.indInstaleap
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
    
    func createJob() -> BehaviorRelay<JobResponse?> {
        let apiResponse: BehaviorRelay<JobResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<JobResponse?, JobServiceRequest>(
                resource: "InstaLeap/CreateJob",
                service: BaseServiceRequestParam<JobServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.CREATE_JOB_INSTALEAP_PROCESS_ID.rawValue
                        ),
                        parametros: getJobRequest()
                    )
                )
            )
        ) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorJobMessage.accept(error.localizedDescription)
                }
            }
        }
        return apiResponse
    }
    
    fileprivate func getJobRequest() -> JobServiceRequest {
        var methodString = "PREPAID"
        if methodSelected?.indTarjeta == 1 {
            methodString = "PAYMENT_LINK"
        } else {
            methodString = "PREPAID"
        }
        
        return JobServiceRequest(
            recipient: RecipientJob(
                identification: IdentificationJob(
                    number: Variables.userProfile?.numeroIdentificacion,
                    type: Variables.userProfile?.tipoIdentificacion
                ),
                name: "\(Variables.userProfile?.nombre ?? "") \(Variables.userProfile?.apellido1 ?? "") \(Variables.userProfile?.apellido2 ?? "")",
                email: Variables.userProfile?.correoElectronico1,
                phone_number: Variables.userProfile?.telefono1 ?? Variables.userProfile?.telefono2
            ),
            payment_info: PaymentInfoJob(
                prices: PricesJob(
                    subtotal: getSubtotalAmount(),
                    shipping_fee: Int(shipping),
                    discounts: Int(getTotalDiscounts()),
                    taxes: 0.0,
                    order_value: getTotalJobAmount() //getSubtotalAmount() + shipping
                ),
                payment: PaymentJob(
                    method: methodString,
                    id: methodSelected?.idFormaPago,
                    payment_status: "SUCCEEDED",
                    reference: carManager.paymentMethod.first?.numTarjeta,
                    value: 0.0
                ),
                currency_code: "CRC"
            ),
            add_delivery_code: true,
            contact_less: ContactLessJob(
                comment: "LeaveAtTheDoor",
                cash_receiver: carManager.shippingMethod?.shippingDescription,
                phone_number: carManager.shippingMethod?.cargoCode
            ),
            slot_id: carManager.hourSelected?.idSlot,
            client_reference: Variables.userProfile?.numeroIdentificacion
        )
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
    
    func getTotalDiscounts() -> Double {
        let products = carManager.carProductsDetail
        let amount = products.map { $0.precioUnitario * Double($0.cantidad) }.reduce(0, +)
        return amount
    }
    
    private func getTotalExpenses() -> Double {
        let products = carManager.carProductsDetail
        return products.map { ($0.totalExpenses ?? 0.0) * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getTotalCSRAmount() -> Double {
        let products = carManager.carProductsDetail
        return products.map { $0.montoExtragar * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getBonoTotalAmount() -> Double {
        let products = carManager.carProductsDetail
        return products.map { ($0.montoBonoProveedor ?? 0.0) * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getTotalDescuentos() -> Double {
        let products = carManager.carProductsDetail
        return products.map { $0.montoDescuento * Double($0.cantidad) }.reduce(0, +)
    }
    
    private func getDeliveryAmountFromCart() -> Double {
        return carManager.shippingMethod?.cost ?? 0.0
    }
    
    private func getTotalJobAmount() -> Double {
        let subtotal = getTotalItemsAmount() + getTotalExpenses() + getTotalCSRAmount()
        let discount = getBonoTotalAmount() + getTotalDescuentos() + getDeliveryAmountFromCart()
        return subtotal - discount
    }
    
    private func getTotalItemsAmount() -> Double {
        let products = carManager.carProductsDetail
        let amount = products.map { $0.montoDescuento * Double($0.cantidad) }.reduce(0, +)
        return amount
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
    
    func verifyCarManagerTypeState() -> String? {
        return defaults.string(forKey: "carManagetTypeStarted")
    }
}
