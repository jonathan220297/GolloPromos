//
//  ProvenanceViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/10/22.
//

import Foundation
import RxRelay

class ProvenanceViewModel {
    private let service = GolloService()
    let carManager = CarManager.shared

    var natilonalities: [Nationalities] = []
    var relationship: [Relationship] = []
    var origin: [Origin] = []

    let nationalitySubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let relationshipSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let originSubject: BehaviorRelay<String?> = BehaviorRelay(value: "")

    func fetchProvenanceData() -> BehaviorRelay<ProvenanceResponse?> {
        let apiResponse: BehaviorRelay<ProvenanceResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(
            BaseRequest<ProvenanceResponse, ProvenanceServiceRequest>(
                resource: "Procesos",
                service: BaseServiceRequestParam<ProvenanceServiceRequest>(
                    servicio: ServicioParam(
                        encabezado: getDefaultBaseHeaderRequest(
                            with: GOLLOAPP.PROVENANCE_PROCESS_ID.rawValue
                        ),
                        parametros: ProvenanceServiceRequest(

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
    
    func setDataToCar() {
        carManager.nationality = nationalitySubject.value
        carManager.kinship = relationshipSubject.value
        carManager.fundsSource = originSubject.value
    }
}
