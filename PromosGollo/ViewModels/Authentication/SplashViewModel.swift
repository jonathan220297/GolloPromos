//
//  SplashViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import FirebaseAuth

class SplashViewModel: NSObject {
    private let defaults = UserDefaults.standard
    private let userManager = UserManager.shared

    func verifyTermsConditionsState() -> Bool {
        return defaults.bool(forKey: "termsConditionsAccepted")
    }

    func setUserData(with data: User) {
        userManager.userData = data
    }

    func verifyUserLogged() -> Bool {
        if let user = Auth.auth().currentUser {
            setUserData(with: user)
            return true
        } else {
            return false
        }
    }
}
