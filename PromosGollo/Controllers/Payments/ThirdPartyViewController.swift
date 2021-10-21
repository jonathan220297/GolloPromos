//
//  ThirdPartyViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/9/21.
//

import UIKit
import DropDown
import RxSwift
import RxCocoa

class ThirdPartyViewController: UIViewController {

    @IBOutlet weak var documentLabel: UILabel!
    @IBOutlet weak var documentTypeButton: UIButton!
    @IBOutlet weak var documentTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var dataView: UIView!
    
    var arrayDocuments = ["Tipo de documento de identidad", "C - Cédula", "J - Cédula Jurídica", "P - Pasaporte"]
    var isDocumentTypeSelected = false
    var selectedDocument = ""

    lazy var viewModel: SearchDocumentViewModel = {
        return SearchDocumentViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
    }

    @IBAction func allDocumentsTapped(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = documentTypeButton
        dropDown.dataSource = arrayDocuments
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            documentLabel.text = item
            if index == 0 {
                isDocumentTypeSelected = false
            } else {
                isDocumentTypeSelected = true
                selectedDocument = arrayDocuments[index - 1]
            }
        }
    }

    @IBAction func searchClient(_ sender: Any) {
        if !isDocumentTypeSelected && documentTextField.text?.isEmpty ?? true {
            showAlert(alertText: "GolloPromos", alertMessage: "Campos Incompletos")
        } else {
            self.fetchCustomer()
        }
    }

    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloPromos", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchCustomer() {
        viewModel.fetchCustomer(with: "C", documentId: "")
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                //self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

}
