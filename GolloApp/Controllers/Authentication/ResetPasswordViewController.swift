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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true

        configureRx()
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

    // MARK: - Functions
    fileprivate func configureRx() {
        sendEmailButton
            .rx
            .tap
            .subscribe(onNext: { _ in
                if let email = self.emailTextField.text {
                    Auth.auth().sendPasswordReset(withEmail: email) { (error) in
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
