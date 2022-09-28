//
//  OfferServiceProtectionViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 16/9/22.
//

import RxSwift
import UIKit

class OfferServiceProtectionViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    
    let bag = DisposeBag()

    // MARK: - Lifecycle
    init() {
        super.init(nibName: "OfferServiceProtectionViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
    }

    
    // MARK: - Functions
    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
}
