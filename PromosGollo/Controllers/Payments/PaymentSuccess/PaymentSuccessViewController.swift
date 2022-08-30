//
//  PaymentSuccessViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 29/8/22.
//

import RxSwift
import UIKit

class PaymentSuccessViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Constants
    let bag = DisposeBag()
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: "PaymentSuccessViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Functions
    func configureRx() {
        backButton
            .rx
            .tap
            .subscribe(onNext: {
                self.popToAccountController()
            })
            .disposed(by: bag)
        
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.popToAccountController()
            })
            .disposed(by: bag)
    }
    
    func popToAccountController() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 5], animated: true)
    }
}
