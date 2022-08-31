//
//  StatusViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/9/21.
//

import UIKit
import RxSwift

class StatusViewController: UIViewController {

    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var paymentAmountView: UIView!
    @IBOutlet weak var cmmLabel: UILabel!
    @IBOutlet weak var cmmUsedLabel: UILabel!
    @IBOutlet weak var cmmAvailableLabel: UILabel!
    @IBOutlet weak var lemLabel: UILabel!
    @IBOutlet weak var lemUsedLabel: UILabel!
    @IBOutlet weak var lemAvailableLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountsView: UIView!
    @IBOutlet weak var totalsView: UIView!
    @IBOutlet weak var initialAmountLabel: UILabel!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var paymentAmountLabel: UILabel!
    @IBOutlet weak var defaultBalanceLabel: UILabel!

    lazy var viewModel: StatusViewModel = {
        return StatusViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Estados de cuenta"

        self.tableView.rowHeight = 310.0
        fetchStatus()
    }

    override func viewDidLayoutSubviews() {
        dataView.roundCorners(corners: [.topRight, .topLeft], radius: 15)
        dataView.layoutIfNeeded()
    }

    @IBAction func hideAccounts(_ sender: Any) {
        accountsView.isHidden = !accountsView.isHidden
    }

    @IBAction func hideTotals(_ sender: Any) {
        totalsView.isHidden = !totalsView.isHidden
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

    fileprivate func fetchStatus() {
        view.activityStarAnimating()
        viewModel.fetchStatus(with: "C", documentId: "205080150")
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                self.showClientCreditInfo(creditInfo: data.datosCredito)
                self.showClientTotals(totals: data.totales)
                self.viewModel.account = data.cuentas ?? []
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    fileprivate func showClientCreditInfo(creditInfo: CreditData?) {
        if let model = creditInfo {
            if let cmm = numberFormatter.string(from: NSNumber(value: model.cmmActual ?? 0.0)) {
                cmmLabel.text = "₡" + " " + String(cmm)
            }
            if let cmm = model.cmmActual,
               let cmmAvailable = model.cmmDisponible {
                let cmmUsed = cmm - cmmAvailable
                if let cmmUsed = numberFormatter.string(from: NSNumber(value: cmmUsed)) {
                    cmmUsedLabel.text = "₡" + " " + String(cmmUsed)
                }
            }
            if let cmmAvailable = numberFormatter.string(from: NSNumber(value: model.cmmDisponible ?? 0.0)) {
                cmmAvailableLabel.text = "₡" + " " + String(cmmAvailable)
            }
            if let lem = numberFormatter.string(from: NSNumber(value: model.lemActual ?? 0.0)) {
                lemLabel.text = "₡" + " " + String(lem)
            }
            if let lem = model.lemActual,
               let lemAvailable = model.lemDisponible {
                let lemUsed = lem - lemAvailable
                if let lemUsed = numberFormatter.string(from: NSNumber(value: lemUsed)) {
                    lemUsedLabel.text = "₡" + " " + String(lemUsed)
                }
            }
            if let lemAvailable = numberFormatter.string(from: NSNumber(value: model.lemDisponible ?? 0.0)) {
                lemAvailableLabel.text = "₡" + " " + String(lemAvailable)
            }
        }
    }

    fileprivate func showClientTotals(totals: [TotalsData]?) {
        if let totals = totals, totals.count > 0 {
            if let initial = numberFormatter.string(from: NSNumber(value: totals[0].totalMontoInicial ?? 0.0)) {
                initialAmountLabel.text = "₡" + " " + String(initial)
            }
            if let payment = numberFormatter.string(from: NSNumber(value: totals[0].totalMontoPago ?? 0.0)) {
                paymentAmountLabel.text = "₡" + " " + String(payment)
            }
            if let current = numberFormatter.string(from: NSNumber(value: totals[0].totalSaldoActual ?? 0.0)) {
                currentBalanceLabel.text = "₡" + " " + String(current)
            }
            if let balance = numberFormatter.string(from: NSNumber(value: totals[0].totalMontoMora ?? 0.0)) {
                defaultBalanceLabel.text = "₡" + " " + String(balance)
            }
        }
    }

}

extension StatusViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.account.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = self.viewModel.account[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell") as! StatusTableViewCell

        cell.setStatus(model: account, index: indexPath.row)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StatusViewController: StatusDelegate {
    func OpenItems(with index: Int) {
        let model = self.viewModel.account[index]
        let vc = ProductDetailViewController.instantiate(fromAppStoryboard: .Payments)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.accountType = "RE"
        vc.accountId = model.idCuenta ?? ""
        self.present(vc, animated: true)
    }
}
