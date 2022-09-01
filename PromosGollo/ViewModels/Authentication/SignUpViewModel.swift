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

    var showConfirmationMessage: (() -> ())?
    var showError: ((_ message: String) -> ())?
    var hideLoading: (()->())?

    var isValidForm: Observable<Bool> {
        return Observable.combineLatest(emailSubject, emailConfirmationSubject, passwordSubject, passwordConfirmationSubject) { email, emailConfirmation, password, passwordConfirmation in

            guard let email = email,
                  let emailConfirmation = emailConfirmation,
                  let password = password,
                  let passwordConfirmation = passwordConfirmation else {
                return false
            }

            let range = NSRange(location: 0, length: password.utf16.count)
            let regex = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{6,}")
            let valid = regex.firstMatch(in: password, options: [], range: range) != nil

            let rangeConfirmation = NSRange(location: 0, length: passwordConfirmation.utf16.count)
            let regexConfirmation = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{6,}")
            let validConfirmation = regexConfirmation.firstMatch(in: passwordConfirmation, options: [], range: rangeConfirmation) != nil

            return !(email.isEmpty)
                && !(emailConfirmation.isEmpty)
                && email.isValidEmail()
                && email == emailConfirmation
                && !(password.isEmpty)
                && !(passwordConfirmation.isEmpty)
                && password == passwordConfirmation
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
