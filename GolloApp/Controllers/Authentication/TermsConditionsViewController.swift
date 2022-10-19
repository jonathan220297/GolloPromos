//
//  TermsConditionsViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import RxSwift
import RxCocoa

class TermsConditionsViewController: UIViewController {
    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBOutlet weak var termsConditionsTextView: UITextView!
    @IBOutlet weak var buttonContinue: UIButton!

    let disposeBag = DisposeBag()

    lazy var viewModel: TermsConditionsViewModel = {
        return TermsConditionsViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        termsConditionsTextView.text = "TermsConditionsController_terms".localized
        configureRx()
    }
}

extension TermsConditionsViewController {
    // MARK: - Actions
}

extension TermsConditionsViewController {
    // MARK: - Functions
    fileprivate func configureRx() {
        viewModel.checkboxSelected
            .asObservable()
            .subscribe(onNext: {[weak self] value in
                guard let self = self else { return }
                if value {
                    self.buttonCheckbox.setImage(UIImage(imageLiteralResourceName: "ic_checked_checkbox"), for: .normal)
                } else {
                    self.buttonCheckbox.setImage(UIImage(imageLiteralResourceName: "ic_unchecked_checkbox"), for: .normal)
                }
        })
        .disposed(by: disposeBag)

        buttonCheckbox.rx.tap.bind {
            self.viewModel.checkboxSelected.accept(!self.viewModel.checkboxSelected.value)
        }
        .disposed(by: disposeBag)

        buttonContinue.rx.tap.bind {
            if !self.viewModel.checkboxSelected.value {
                self.showAlert(alertText: "GolloApp", alertMessage: "TermsConditionsController_continue_error".localized)
            } else {
                print("Nice")
                self.viewModel.setCheckboxValueToUserDefaults()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        .disposed(by: disposeBag)
    }
}
