//
//  PaymentJobSelectionViewModel.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 3/1/24.
//

import Foundation
import RxRelay
import UIKit

class PaymentJobSelectionViewModel {
    private let service = GolloService()
    private let defaults = UserDefaults.standard
    
    let carManager = CarManager.shared
    
    var slotAvailabilities: [SlotAvailabilityResponse] = []
    var responseDate: [ResponseDate] = []
    var hoursAvailabilities: [ResponseHours] = []
    var dateSelected: ResponseDate? = nil
    var hourSelected: ResponseHours? = nil
    
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
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
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        return apiResponse
    }
    
    fileprivate func getSlotsRequest() -> SlotAvailabilityServiceRequest {
        var products: [JobItems] = []
        
        let destination = Destination(
            name: getStoreCode(data: carManager.shopSelected?.nombre ?? ""),
            address: carManager.shopSelected?.direccion,
            description: carManager.shopSelected?.direccion,
            latitude: carManager.shopSelected?.latitud,
            longitude: carManager.shopSelected?.longitud
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

        let addStartHoursStore = carManager.shopSelected?.horasInicioPicking ?? 0

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
            operational_models_priority: ["PICK_AND_DELIVERY_WITH_STORAGE_NO_TRANSFER"],
            fallback: false,
            store_reference: getStoreCode(data: carManager.shopSelected?.nombre ?? ""),
            job_items: products
        )
    }
    
    fileprivate func getStoreCode(data: String) -> String {
        let matchResult = data.range(of: "^\\d+", options: .regularExpression)
        let matchValue = matchResult?.lowerBound != nil ? String(data[matchResult!]) : ""
        return matchValue
    }
}
