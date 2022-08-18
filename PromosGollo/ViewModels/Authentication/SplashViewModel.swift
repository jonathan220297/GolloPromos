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

    func sessionExpired() -> Bool {
        let jwt = getToken()
        // get the payload part of it
        var payload64 = jwt.components(separatedBy: ".")[1]

        // need to pad the string with = to make it divisible by 4,
        // otherwise Data won't be able to decode it
        while payload64.count % 4 != 0 {
            payload64 += "="
        }

        print("base64 encoded payload: \(payload64)")
        let payloadData = Data(base64Encoded: payload64,
                               options:.ignoreUnknownCharacters)!
        let payload = String(data: payloadData, encoding: .utf8)!
        print(payload)

        let json = try! JSONSerialization.jsonObject(with: payloadData, options: []) as! [String:Any]
        let exp = json["exp"] as! Int
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        if expDate.compare(Date()) == .orderedDescending {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                debugPrint("Logout error \(signOutError)")
            }
        }
        return expDate.compare(Date()) == .orderedDescending
    }
}
