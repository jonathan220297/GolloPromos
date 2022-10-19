//
//  AddressListViewModel.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import Foundation
import RxRelay

class AddressListViewModel {
    private let service = GolloService()
    
    var addressArray: [UserAddress] = []
    
    func fetchAdress() -> BehaviorRelay<AddressListResponse?> {
        let apiResponse: BehaviorRelay<AddressListResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<AddressListResponse, AddressListRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<AddressListRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.ADDRESS_LIST.rawValue
                        ),
                        parametros: AddressListRequest(
                            idCliente: Variables.userProfile?.idCliente ?? ""
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
    
    func deleteAddress(with addressID: Int) -> BehaviorRelay<Bool?> {
        let apiResponse: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<Bool?, DeleteAddress>(
                resource: "Procesos",
                service: BaseServiceRequestParam<DeleteAddress>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.DELETE_ADDRESS.rawValue
                        ),
                        parametros: DeleteAddress(
                            idCliente: Variables.userProfile?.idCliente ?? "",
                            idDireccion: addressID
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
}
