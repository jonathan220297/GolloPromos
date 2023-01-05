//
//  PaymentConfirmViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 28/9/22.
//

import Foundation
import RxRelay

class PaymentConfirmViewModel {
    private let service = GolloService()
    let carManager = CarManager.shared
    
    var methods: [PaymentMethodResponse] = []
    var methodSelected: PaymentMethodResponse?
    
    var subTotal = 0.0
    var shipping = 0.0
    var bonus = 0.0
    var isAccountPayment = true
    
    let errorMessage = BehaviorRelay<String?>(value: nil)

    func fetchPaymentMethods() -> BehaviorRelay<[PaymentMethodResponse]?> {
        let apiResponse: BehaviorRelay<[PaymentMethodResponse]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(BaseRequest<[PaymentMethodResponse], PaymentMethodServiceRequest>(
            service: BaseServiceRequestParam<PaymentMethodServiceRequest>(
                servicio: ServicioParam(
                    encabezado: Encabezado(
                        idProceso: GOLLOAPP.PAYMENT_METHODS_PROCESS_ID.rawValue,
                        idDevice: getDeviceID(),
                        idUsuario: UserManager.shared.userData?.uid ?? "",
                        timeStamp: String(Date().timeIntervalSince1970),
                        idCia: 10,
                        token: getToken(),
                        integrationId: nil
                    ),
                    parametros: PaymentMethodServiceRequest (
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
                       indPrincipal: 0
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
               indPrincipal: methodSelected?.indPrincipal ?? 0
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
        let products = carManager.car
        let amount = products.map { ($0.precioUnitario - $0.montoDescuento - ($0.montoBonoProveedor ?? 0.0)) * Double($0.cantidad) }.reduce(0, +)
        let plus = products.map { $0.montoExtragar * Double($0.cantidad) }.reduce(0, +) 
        return amount + plus
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
        return orderItems
    }
}
