//
//  UserManager.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import FirebaseAuth

class UserManager: NSObject {
    static let shared = UserManager()

    var userData: User?
}
