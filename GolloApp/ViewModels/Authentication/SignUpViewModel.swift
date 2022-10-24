//
//  SignUpViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import Foundation
import RxSwift
import RxRelay

class SignUpViewModel: NSObject {
    private let minimalPasswordLength = 6
    private let authService = AuthenticationService()
    private let userManager = UserManager.shared

    let emailSubject = BehaviorRelay<String?>(value: "")
    let emailConfirmationSubject = BehaviorRelay<String?>(value: "")
    let passwordSubject = BehaviorRelay<String?>(value: "")
    let passwordConfirmationSubject = BehaviorRelay<String?>(value: "")
    let passwordErrorSubject = BehaviorRelay<Bool?>(value: nil)

    var showConfirmationMessage: (() -> ())?
    var showError: ((_ message: String) -> ())?
    var hideLoading: (()->())?

    var isValidForm: Observable<Bool> {
        return Observable.combineLatest(emailSubject, passwordSubject) { email, password in

            guard let email = email,
                  let password = password else {
                return false
            }

            let range = NSRange(location: 0, length: password.utf16.count)
            let regex = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{6,}")
            let valid = regex.firstMatch(in: password, options: [], range: range) != nil

            let rangeConfirmation = NSRange(location: 0, length: password.utf16.count)
            let regexConfirmation = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{6,}")
            let validConfirmation = regexConfirmation.firstMatch(in: password, options: [], range: rangeConfirmation) != nil
            
            if !password.isEmpty {
                self.passwordErrorSubject.accept(!(valid && validConfirmation))
            }

            return !(email.isEmpty)
                && email.isValidEmail()
                && !(password.isEmpty)
                && password.count > self.minimalPasswordLength
                && valid
                && validConfirmation
        }
    }

    func signUp(with email: String, _ password: String) {
        authService.signUp(with: email, password) {[weak self] user, error in
            guard let user = user,
                  let self = self else {
//                self?.hideLoading?()
//                self?.showError?(error ?? "")
                return
            }
            self.userManager.userData = user
            self.showConfirmationMessage?()
        }
    }
}
