//
//  ResetPasswordViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 25/8/22.
//

import UIKit
import RxSwift
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    let disposeBag = DisposeBag()
    var keyboardShowing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        configureRx()
        emailTextField.delegate = self
    }

    // MARK: - Observers
    @objc func closePopUp() {
        if !keyboardShowing {
            dismiss(animated: true)
        } else {
            hideKeyboardWhenTappedAround()
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardShowing = true
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardShowing = false
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    // MARK: - Functions
    fileprivate func configureRx() {
        sendEmailButton
            .rx
            .tap
            .subscribe(onNext: { _ in
                if let email = self.emailTextField.text {
                    Auth.auth().sendPasswordReset(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines)) { (error) in
                        if let error = error {
                            self.showAlert(alertText: "GolloApp", alertMessage: error.localizedDescription)
                        } else {
                            self.dismiss(animated: true)
                            self.showAlert(alertText: "GolloApp", alertMessage: "Se ha enviado el cambio de contraseña")
                        }
                    }
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Ingrese el correo electrónico")
                }
            })
            .disposed(by: disposeBag)

        cancelButton
            .rx
            .tap
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }

}

// MARK: - UIGestureRecognizer Delegates
extension ResetPasswordViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.viewGlass) {
            return true
        }
        return false
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
            self.view.endEditing(true)
            return true
        }
}
