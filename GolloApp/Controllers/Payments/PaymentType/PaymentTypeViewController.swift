//
//  PaymentTypeViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 31/12/23.
//

import RxSwift
import UIKit

protocol PaymentTypeDelegate: AnyObject {
    func continuePayment(with creditSelected: Bool)
}

class PaymentTypeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var creditButton: UIButton!
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var emmaButton: UIButton!
    @IBOutlet weak var continuePaymentButton: UIButton!
    
    let bag = DisposeBag()
    let delegate: PaymentTypeDelegate
    
    var isCreditSelected: Bool?
    
    init(delegate: PaymentTypeDelegate) {
        self.delegate = delegate
        super.init(nibName: "PaymentTypeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureRx()
    }
    
    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }
    
    // MARK: - Function
    func configureViews() {
        popUpView.layer.cornerRadius = 15
        continuePaymentButton.layer.masksToBounds = true
        continuePaymentButton.layer.cornerRadius = 10
        continuePaymentButton.layoutIfNeeded()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        viewGlass.addGestureRecognizer(tapRecognizer)
        viewGlass.isUserInteractionEnabled = true
    }

    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: bag)
        
        creditButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.isCreditSelected = true
                self.creditButton.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
                self.cashButton.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
                self.emmaButton.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
            })
            .disposed(by: bag)
        
        cashButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.isCreditSelected = false
                self.creditButton.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
                self.cashButton.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
                self.emmaButton.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
            })
            .disposed(by: bag)
        
        emmaButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.isCreditSelected = false
                self.creditButton.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
                self.cashButton.setImage(UIImage(named: "ic_radio-button-unchecked"), for: .normal)
                self.emmaButton.setImage(UIImage(named: "ic_radio-button-checked"), for: .normal)
            })
            .disposed(by: bag)
        
        continuePaymentButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if let selection = self.isCreditSelected {
                    self.dismiss(animated: true) {
                        self.delegate.continuePayment(with: selection)
                    }
                }
            })
            .disposed(by: bag)
    }
}

// MARK: - UIGestureRecognizer Delegates
extension PaymentTypeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.viewGlass) {
            return true
        }
        return false
    }
}
