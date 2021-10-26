//
//  EditProfileViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxRelay

class EditProfileViewModel {
    private let firebaseService = FirebaseService()
    let userManager = UserManager.shared
    let errorMessage: BehaviorRelay<String> = BehaviorRelay(value: "")
    var docTypes: [DocType] = []
    
    func uploadPhoto(profileImage: UIImage?, firstName: String?, lastNames: String?, birthDate: Date?) {
        firebaseService.uploadPhoto(with: userManager.userData?.uid ?? "ShoppiImage", userManager.userData?.email ?? "", profileImage: profileImage, firstName: firstName, lastNames: lastNames, birthDate: birthDate) {[weak self] error in
            if let error = error {
                self?.errorMessage.accept(error)
            }
        }
    }
    
    func processDocTypes() {
        docTypes.append(DocType(code: "C", name: "ProfileViewController_cedula".localized))
        docTypes.append(DocType(code: "J", name: "ProfileViewController_cedula_juridica".localized))
        docTypes.append(DocType(code: "P", name: "ProfileViewController_passport".localized))
    }
}

