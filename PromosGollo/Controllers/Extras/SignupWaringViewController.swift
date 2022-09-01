//
//  SignupWaringViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 1/9/22.
//

import RxSwift
import UIKit

protocol SignupWarningDelegate: AnyObject {
    func didTapSignupButton()
}

class SignupWaringViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let bag = DisposeBag()
    let delegate: SignupWarningDelegate
    
    // MARK: - Lifecycle
    init(delegate: SignupWarningDelegate) {
        self.delegate = delegate
        super.init(nibName: "SignupWaringViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        configureRx()
    }
    
    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }
    
    // MARK: - Functions
    func configureGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        glassView.addGestureRecognizer(tapRecognizer)
        glassView.isUserInteractionEnabled = true
    }
    
    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: bag)
        
        signupButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true) {
                    self.delegate.didTapSignupButton()
                }
            })
            .disposed(by: bag)
    }
}

extension SignupWaringViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizer Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: glassView) {
            return true
        }
        return false
    }
}
