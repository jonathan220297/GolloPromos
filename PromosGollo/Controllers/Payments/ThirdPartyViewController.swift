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
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerDocumentLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var isDocumentTypeSelected = false
    var selectedDocument = ""

    lazy var viewModel: SearchDocumentViewModel = {
        let vm = SearchDocumentViewModel()
        vm.processDocTypes()
        return vm
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Compras a crédito activas de terceros"
        self.tabBarController?.tabBar.isHidden = true

        self.tableView.rowHeight = 140.0
        configureRx()
    }

    @IBAction func allDocumentsTapped(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = documentTypeButton
        dropDown.dataSource = viewModel.docTypes.map { $0.name }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            isDocumentTypeSelected = true
            selectedDocument = viewModel.docTypes[index].code
            documentLabel.text = item
        }
    }

    @IBAction func searchClient(_ sender: Any) {
        if !isDocumentTypeSelected && documentTextField.text?.isEmpty ?? true {
            showAlert(alertText: "GolloApp", alertMessage: "Campos Incompletos")
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
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchCustomer() {
        viewModel.fetchCustomer(with: selectedDocument, documentId: documentTextField.text!)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let type = data.tipoIdentificacion,
                   let number = data.numeroIdentificacion {
                    if let name = data.nombre,
                       let lastName = data.apellido1,
                       let secondLastName = data.apellido2 {
                        self.customerNameLabel.text = name + " " + lastName + " " + secondLastName
                    }
                    self.tabBarController?.navigationItem.title = "Cuentas activas de terceros"
                    self.customerDocumentLabel.text = "Cedula: \(number)"
                    self.fetchCustomerAccounts(documentType: type, documentId: number)
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(alertText: "GolloApp", alertMessage: "Usuario no encontrado.")
                    }
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchCustomerAccounts(documentType: String, documentId: String) {
        view.activityStarAnimating()
        viewModel.fetchAccounts(with: documentType, documentId: documentId)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                self.searchView.alpha = 0
                self.dataView.alpha = 1
                self.viewModel.accounts = data
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

}

// MARK: - Extension Table View
extension ThirdPartyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = self.viewModel.accounts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell") as! ThirdPartyAccountsTableViewCell

        cell.setAccount(model: account, index: indexPath.row)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.viewModel.accounts[indexPath.row]
        let vc = PaymentViewController.instantiate(fromAppStoryboard: .Payments)
        vc.modalPresentationStyle = .fullScreen
        let payment = PaymentData()
        payment.currency = ""
        payment.suggestedAmount = model.montoSugeridoBotonera
        payment.installmentAmount = model.montoCuota
        payment.totalAmount = model.montoCancelarCuenta
        payment.idCuenta = model.idCuenta
        payment.numCuenta = model.numCuenta
        payment.type = 1
        payment.documentId = Variables.userProfile?.numeroIdentificacion ?? "205080150"
        payment.documentType = Variables.userProfile?.tipoIdentificacion ?? "C"
        payment.nombreCliente = ""
        payment.email = ""
        vc.paymentData = payment
        vc.isThirdPayAccount = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


