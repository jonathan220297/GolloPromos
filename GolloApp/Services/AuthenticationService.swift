//
//  AuthenticationService.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

class AuthenticationService {
    func signUp(with email: String, _ password: String, completion: @escaping(_ user: User?, _ error: String?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            guard let authDataResult = authDataResult else {
                completion(nil, error?.localizedDescription)
                return
            }
            if !authDataResult.user.isEmailVerified {
                authDataResult.user.sendEmailVerification { error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
            completion(authDataResult.user, nil)
        }
    }

    func signIn(with credential: AuthCredential, completion: @escaping(_ user: User?, _ error: String?) -> ()) {
        Auth.auth().signIn(with: credential) { authDataResult, error in
            guard let authDataResult = authDataResult else {
                completion(nil, error?.localizedDescription)
                return
            }
            completion(authDataResult.user, nil)
        }
    }

    func signIn(with email: String, _ password: String, completion: @escaping(_ user: User?, _ error: String?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            guard let authDataResult = authDataResult else {
                completion(nil, error?.localizedDescription)
                return
            }
            completion(authDataResult.user, nil)
        }
    }
}
