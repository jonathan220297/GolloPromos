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
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{6,}"
        return Observable.combineLatest(emailSubject, emailConfirmationSubject, passwordSubject, passwordConfirmationSubject) { email, emailConfirmation, password, passwordConfirmation in

            guard let email = email,
                  let emailConfirmation = emailConfirmation,
                  let password = password,
                  let passwordConfirmation = passwordConfirmation else {
                return false
            }

            return !(email.isEmpty)
                && !(emailConfirmation.isEmpty)
                && email.isValidEmail()
                && email == emailConfirmation
                && !(password.isEmpty)
                && !(passwordConfirmation.isEmpty)
                && password == passwordConfirmation
                && password.count > self.minimalPasswordLength
                && NSPredicate(format: password, passwordRegex).evaluate(with: self)
                && NSPredicate(format: passwordConfirmation, passwordRegex).evaluate(with: self)
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
