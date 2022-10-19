//
//  FirebaseService.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class FirebaseService {
    func uploadPhoto(with userID: String, _ userEmail: String, profileImage: UIImage?, firstName: String?, lastNames: String?, birthDate: Date?, completion: @escaping(_ error: String?) -> ())  {
        guard let image = profileImage, let data = image.jpegData(compressionQuality: 1.0)
            else {
                return
        }

        let imageName = UUID.init(uuidString: userID)

        let imageReference = Storage.storage().reference()
            .child("profileImages")
            .child(imageName?.uuidString ?? "")

        imageReference.putData(data, metadata: nil) { (metadata, err) in
            if let err = err {
                completion(err.localizedDescription)

            }

            imageReference.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err.localizedDescription)
                }

                guard let url = url else {
                    completion("Cannot parse image URL.")
                    return
                }

                let urlString = url.absoluteString

                let docData: [String: Any] = [
                    "birthDate": Timestamp(date: birthDate ?? Date()),
                    "isOnline" : true,
                    "firstName": firstName ?? "",
                    "lastName" : lastNames ?? "",
                    "picture": urlString,
                    "token" : ""
                ]

                self.addData(userEmail: userEmail, data: docData) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }

            })
        }
    }

    func addData(userEmail: String, data: [String: Any], completion: @escaping(_ error: String?) -> ()) {
        Firestore.firestore().collection("users").document(userEmail).updateData(data) { err in
            if let err = err {
                completion(err.localizedDescription)
                return
            }
            completion(nil)
        }
    }
}

