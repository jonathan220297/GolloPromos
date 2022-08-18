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

}
