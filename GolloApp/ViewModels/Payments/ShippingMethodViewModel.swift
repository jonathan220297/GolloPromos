//
//  ShippingMethodViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation
import RxRelay
import UIKit

class ShippingMethodViewModel {
    private let service = GolloService()
    private let defaults = UserDefaults.standard
    
    let carManager = CarManager.shared
    
    var methods: [ShippingMethodData] = []
    var data: [ShopData] = []
    var states: [String] = []
    var shops: [ShopData] = []
    var slotAvailabilities: [SlotAvailabilityResponse] = []
    var responseDate: [ResponseDate] = []
    var hoursAvailabilities: [ResponseHours] = []
    var shopSelected: ShopData?
    var stateSelected = ""
    var methodSelected: ShippingMethodData?
    var hasInstaleap: Bool = false
    var dateSelected: ResponseDate? = nil
    var hourSelected: ResponseHours? = nil
    
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let errorSlotsMessage = BehaviorRelay<String?>(value: nil)
    
    func setShippingMethods(_ selected: Bool) {
        methods.append(
            ShippingMethodData(
                cargoCode: "-1",
                shippingType: "Recoger en tienda",
                shippingDescription: "Recoger sus productos en cualquiera de nuestras tiendas en todo el país",
                cost: 0.0,
                selected: selected
            )
        )
    }
    
    func fetchShops() -> BehaviorRelay<[ShopData]?> {
        let apiResponse: BehaviorRelay<[ShopData]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<[ShopData]?, ShopsListRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<ShopsListRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.OFFER_STORES_PROCESS_ID.rawValue
                        ),
                        parametros: ShopsListRequest(
                            idCompania: "10"
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
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
    
    func fetchSlots() -> BehaviorRelay<[SlotAvailabilityResponse]?> {
        let apiResponse: BehaviorRelay<[SlotAvailabilityResponse]?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<[SlotAvailabilityResponse]?, SlotAvailabilityServiceRequest>(
                resource: "InstaLeap/Availability",
                service: BaseServiceRequestParam<SlotAvailabilityServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.GET_SLOTS_PROCESS_ID.rawValue
                        ),
                        parametros: getSlotsRequest()
                    )
                )
            )
        ) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let response):
                    apiResponse.accept(response)
                case .failure(let error):
                    self.errorSlotsMessage.accept(error.errorDescription)
                }
            }
        }
        return apiResponse
    }
    
    func fetchDeliveryMethods(idState: String, idCounty: String, idDistrict: String) -> BehaviorRelay<DeliveryMethodsResponse?> {
        var paymentForm = 0
        if carManager.payWithPreApproved {
            paymentForm = 1
        } else {
            paymentForm = 0
        }
        
        let apiResponse: BehaviorRelay<DeliveryMethodsResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<DeliveryMethodsResponse?, DeliveryMethodsServiceRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<DeliveryMethodsServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.FREIGHTS_PROCESS_ID.rawValue
                        ),
                        parametros: DeliveryMethodsServiceRequest(
                            idCanton: idCounty,
                            idDistrito: idDistrict,
                            idProvincia: idState,
                            indVMI: carManager.carHasVMI(),
                            monto: carManager.total,
                            formaPago: paymentForm
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
                    self.errorMessage.accept(error.errorDescription)
                }
            }
        }
        return apiResponse
    }
    
    func processStates(with data: [ShopData]) {
        for item in data {
            if !states.contains(where: { state in
                state == item.provincia
            }) {
                states.append(item.provincia ?? "")
            }
        }
        states.sort { state1, state2 in
            state1 < state2
        }
    }
    
    func processShops(with state: String) {
        shops = data.filter({ data in
            data.provincia == state
        })
    }
    
    func processShippingMethod() {
        var deliveryType = "20"
        if methodSelected?.cargoCode == "-1" {
            deliveryType = "20"
        } else {
            deliveryType = methodSelected?.cargoCode ?? ""
        }
        carManager.shippingMethod = methodSelected
        carManager.deliveryInfo?.lugarDespacho = shopSelected?.idTienda ?? ""
        carManager.deliveryInfo?.tipoEntrega = deliveryType
        carManager.deliveryInfo?.codigoFlete = carManager.shippingMethod?.cargoCode ?? "-1"
        carManager.deliveryInfo?.montoFlete = carManager.shippingMethod?.cost ?? 0.0
        carManager.hasIntaleap = hasInstaleap
        carManager.dateSelected = dateSelected
        carManager.hourSelected = hourSelected
        carManager.shopSelected = shopSelected
    }
    
    func findSelectedStore() -> ShopData? {
        let store = data.filter({ data in
            data.idTienda == verifyCarManagerStoreID() ?? ""
        })
        return store.first
    }
    
    func findUserNearStore() -> ShopData? {
        do {
            let previousSelectedProvince = try defaults.getObject(forKey: "Province", castTo: State?.self)
            let store = data.filter({ data in
                data.provincia?.contains(previousSelectedProvince?.provincia ?? "") == true
            })
            return store.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func verifyCarManagerTypeState() -> String? {
        return defaults.string(forKey: "carManagetTypeStarted")
    }
    
    func verifyCarManagerStoreID() -> String? {
        return defaults.string(forKey: "carManagerStoreID")
    }
    
    fileprivate func getSlotsRequest() -> SlotAvailabilityServiceRequest {
        var products: [JobItems] = []
        
        let destination = Destination(
            name: getStoreCode(data: shopSelected?.nombre ?? ""),
            address: shopSelected?.direccion,
            description: shopSelected?.direccion,
            latitude: shopSelected?.latitud,
            longitude: shopSelected?.longitud
        )
        
        for item in carManager.car {
            products.append(
                JobItems(
                    quantity_found_limits: QuantityFoundLimits(max: item.cantidad, min: item.cantidad),
                    id: item.sku,
                    name: item.descripcion,
                    photo_url: "",
                    unit: "PZ",
                    sub_unit: "PZ",
                    quantity: item.cantidad,
                    sub_quantity: item.cantidad,
                    price: item.precioUnitario
                )
            )
        }
        
        let now = Date()
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = Calendar.current.component(.year, from: now)
        dateComponents.month = Calendar.current.component(.month, from: now)
        dateComponents.day = Calendar.current.component(.day, from: now)
        dateComponents.hour = Calendar.current.component(.hour, from: now)
        dateComponents.minute = Calendar.current.component(.minute, from: now)
        dateComponents.second = Calendar.current.component(.second, from: now)
        let startDateFormatted = calendar.date(from: dateComponents)!

        var endDateComponents = DateComponents()
        endDateComponents.year = Calendar.current.component(.year, from: startDateFormatted)
        endDateComponents.month = Calendar.current.component(.month, from: startDateFormatted)
        endDateComponents.day = Calendar.current.component(.day, from: startDateFormatted)
        endDateComponents.hour = Calendar.current.component(.hour, from: startDateFormatted)
        endDateComponents.minute = Calendar.current.component(.minute, from: startDateFormatted)
        endDateComponents.second = Calendar.current.component(.second, from: startDateFormatted)
        endDateComponents.day! += 7
        let endDate = calendar.date(from: endDateComponents)!

        let addStartHoursStore = shopSelected?.horasInicioPicking ?? 0

        var startDateStoreSelectedComponents = DateComponents()
        startDateStoreSelectedComponents.year = Calendar.current.component(.year, from: startDateFormatted)
        startDateStoreSelectedComponents.month = Calendar.current.component(.month, from: startDateFormatted)
        startDateStoreSelectedComponents.day = Calendar.current.component(.day, from: startDateFormatted)
        startDateStoreSelectedComponents.hour = Calendar.current.component(.hour, from: startDateFormatted)
        startDateStoreSelectedComponents.minute = Calendar.current.component(.minute, from: startDateFormatted)
        startDateStoreSelectedComponents.second = Calendar.current.component(.second, from: startDateFormatted)
        startDateStoreSelectedComponents.hour! += addStartHoursStore
        let startDateStoreSelected = calendar.date(from: startDateStoreSelectedComponents)!
        
        return SlotAvailabilityServiceRequest(
            origin: destination,
            destination: destination,
            currency_code: "CRC",
            start: formatDate.string(from: startDateStoreSelected),
            end: formatDate.string(from: endDate),
            slot_size: 60,
            minimum_slot_size: 60,
            operational_models_priority: ["PICK_AND_COLLECT_NO_TRANSFER"],
            fallback: false,
            store_reference: getStoreCode(data: shopSelected?.nombre ?? ""),
            job_items: products
        )
    }
    
    fileprivate func getStoreCode(data: String) -> String {
        let matchResult = data.range(of: "^\\d+", options: .regularExpression)
        let matchValue = matchResult?.lowerBound != nil ? String(data[matchResult!]) : ""
        return matchValue
    }
}
