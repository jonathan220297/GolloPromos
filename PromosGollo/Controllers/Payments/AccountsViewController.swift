//
//  AccountsViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift

class AccountsViewController: UIViewController {

    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var containerDataView: UIView!
    @IBOutlet weak var emptyDataView: UIView!
    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel: AccountsViewModel = {
        return AccountsViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        tableView.rowHeight = 300.0
        fetchAccounts()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.title = "Cuentas"
    }

    override func viewDidLayoutSubviews() {
        containerDataView.roundCorners(corners: [.topRight, .topLeft], radius: 15)
        containerDataView.layoutIfNeeded()
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

    fileprivate func fetchAccounts() {
        viewModel.fetchAccounts(with: "C", documentId: "205080150")
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if data.isEmpty {
                    self.dataView.alpha = 0
                }
                self.viewModel.accounts = data
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
}



// MARK: - Extension Table View
extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = self.viewModel.accounts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountsCell") as! AccountsTableViewCell

        cell.setAccount(model: account, index: indexPath.row)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.viewModel.accounts[indexPath.row]
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "paymentVC") as! PaymentViewController
//        viewController.modalPresentationStyle = .overCurrentContext
//        viewController.modalTransitionStyle = .crossDissolve
//        let payment = PaymentData()
//        payment.currency = Constants.DEFAULT_CURRENCY_SYMBOL
//        payment.suggestedAmount = model.montoSugeridoBotonera
//        payment.installmentAmount = model.montoCuota
//        payment.totalAmount = model.montoCancelarCuenta
//        payment.idCuenta = model.idCuenta
//        payment.numCuenta = model.numCuenta
//        payment.type = PaymentType.ACCOUNT
//        payment.documentId = Constants.actualClientInfo?.identificacion
//        payment.documentType = Constants.actualClientInfo?.tipoIdentificacion
//        payment.nombreCliente = Constants.actualClientInfo?.nombre
//        payment.email = Constants.actualClientInfo?.correoElectronico
//        viewController.paymentData = payment
//        self.present(viewController, animated: true)
    }
}

extension AccountsViewController: AccountsDelegate {
    func OpenItems(with index: Int) {
        let model = self.viewModel.accounts[index]
        let storyboard = UIStoryboard(name: "Payments", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "productDetailVC") as! ProductDetailViewController
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        viewController.accountType = "RE"
        viewController.accountId = model.idCuenta ?? ""
        self.present(viewController, animated: true)
    }
}

