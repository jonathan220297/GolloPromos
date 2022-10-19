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

        navigationItem.title = "Mis compras a crédito"

        tableView.rowHeight = 335.0
        tableView.tableFooterView = UIView()
        fetchAccounts()
        configureRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
                    self.view.activityStopAnimating()
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                    self.tableView.alpha = 0
                    self.emptyDataView.alpha = 1
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchAccounts() {
        self.view.activityStarAnimating()
        viewModel.fetchAccounts(with: Variables.userProfile?.tipoIdentificacion ?? "C", documentId: Variables.userProfile?.numeroIdentificacion ?? "205080150")
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if data.isEmpty {
                    self.emptyDataView.alpha = 1
                    self.tableView.alpha = 0
                } else {
                    self.emptyDataView.alpha = 0
                    self.tableView.alpha = 111
                }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
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
        let vc = PaymentViewController.instantiate(fromAppStoryboard: .Payments)
        vc.modalPresentationStyle = .fullScreen
        let payment = PaymentData()
        payment.currency = GOLLOAPP.CURRENCY_SIMBOL.rawValue
        payment.suggestedAmount = model.montoSugeridoBotonera
        payment.installmentAmount = model.montoCuota
        payment.totalAmount = model.montoCancelarCuenta
        payment.idCuenta = model.idCuenta
        payment.numCuenta = model.numCuenta
        payment.type = 1
        payment.documentId = Variables.userProfile?.numeroIdentificacion ?? "205080150"
        payment.documentType = Variables.userProfile?.tipoIdentificacion ?? "C"
        payment.nombreCliente = "\(Variables.userProfile?.nombre ?? "") \(Variables.userProfile?.apellido1 ?? "")"
        payment.email = Variables.userProfile?.correoElectronico1 ?? ""
        vc.paymentData = payment
        vc.isThirdPayAccount = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AccountsViewController: AccountsDelegate {
    func OpenItems(with index: Int) {
        let model = self.viewModel.accounts[index]
        let vc = ProductDetailViewController.instantiate(fromAppStoryboard: .Payments)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.accountType = "RE"
        vc.accountId = model.idCuenta ?? ""
        self.present(vc, animated: true)
    }

    func OpenHistory(with index: Int) {
        let vc = TransactionsHistoryViewController.instantiate(fromAppStoryboard: .Payments)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

