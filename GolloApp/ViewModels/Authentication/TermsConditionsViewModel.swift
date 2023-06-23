//
//  TermsConditionsViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import RxSwift
import RxRelay

class TermsConditionsViewModel: NSObject {
    
    private let defaults = UserDefaults.standard

    var checkboxSelected: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    func setCheckboxValueToUserDefaults() {
        defaults.setValue(checkboxSelected.value, forKey: "termsConditionsAccepted")
    }

    func verifyTermsConditionsState() -> Bool {
        return defaults.bool(forKey: "termsConditionsAccepted")
    }
    
}
