//
//  ThirdPartyViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/8/22.
//

import Foundation
import RxRelay

class TransactionsHistoryViewModel {
    private let service = GolloService()

    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")

    var reloadTableViewData: (()->())?

    var transactionsNumber: [Int] = []
    var payments: [Payments] = []

    func fetchTransactionHistory(with transactions: Int, accountId: String) -> BehaviorRelay<TransactionHistoryResponse?> {
        let apiResponse: BehaviorRelay<TransactionHistoryResponse?> = BehaviorRelay(value: nil)
        service.callWebServiceGollo(TransactionHistoryRequest(service: BaseServiceRequestParam<TransactionHistoryServiceRequest>(
            servicio: ServicioParam(
                encabezado: getDefaultBaseHeaderRequest(with: GOLLOAPP.ACCOUNT_PAYMENT_HISTORY.rawValue),
                parametros: TransactionHistoryServiceRequest (
                    empresa: "10",
                    idCliente: Variables.userProfile?.numeroIdentificacion ?? "205080150",
                    idCuenta: accountId,
                    idOrigen: "Promos",
                    numPagos: transactions,
                    tipoId: "C"
                )
            )
        ))) { response in
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

    func processTransactions() {
        transactionsNumber.append(10)
        transactionsNumber.append(20)
        transactionsNumber.append(30)
        transactionsNumber.append(40)
        transactionsNumber.append(50)
    }

}
