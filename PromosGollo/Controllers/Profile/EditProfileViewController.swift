//
//  EditProfileViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var documentTypeLabel: UILabel!
    @IBOutlet weak var documentTypeButton: UIButton!
    @IBOutlet weak var documentNumberLabel: UITextField!
    @IBOutlet weak var searchCustomerButton: UIButton!
    
    lazy var viewModel: EditProfileViewModel = {
        let vm = EditProfileViewModel()
        vm.processDocTypes()
        return vm
    }()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Perfil de usuario"
        configureRx()

        hideKeyboardWhenTappedAround()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Observers

    // MARK: - Functions
    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] message in
                guard let self = self else { return }
                if !message.isEmpty {
                    self.showAlert(alertText: "GolloPromos", alertMessage: message)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: disposeBag)
        
        documentTypeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.configureDocumentTypeDropDown()
            })
            .disposed(by: disposeBag)
    }
    
    func configureDocumentTypeDropDown() {
        let dropDown = DropDown()
        dropDown.anchorView = documentTypeButton
        dropDown.dataSource = viewModel.docTypes.map { $0.name }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            documentTypeLabel.text = item
        }
    }
}
