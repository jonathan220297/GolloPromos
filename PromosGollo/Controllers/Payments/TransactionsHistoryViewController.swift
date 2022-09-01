//
//  TransactionsHistoryViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/8/22.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown

class TransactionsHistoryViewController: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var modifyItemsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel: TransactionsHistoryViewModel = {
        let vm = TransactionsHistoryViewModel()
        vm.processTransactions()
        return vm
    }()
    let bag = DisposeBag()

    var actualTransactionNumber = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "HistoryViewController"
        self.numberLabel.text = "10"
        self.tableView.rowHeight = 240.0
        configureRx()
        fetchHistory(number: actualTransactionNumber)
    }

    // MARK: - Functions
    fileprivate func configureRx() {
        modifyItemsButton
            .rx
            .tap
            .subscribe(onNext: {
                self.configureTransactionDropDown()
            })
            .disposed(by: bag)

        searchButton
            .rx
            .tap
            .subscribe(onNext: {
                self.fetchHistory(number: self.actualTransactionNumber)
            })
            .disposed(by: bag)
    }

    fileprivate func fetchHistory(number: Int) {
        view.activityStarAnimating()
        viewModel.fetchTransactionHistory(with: number, accountId: "152004009140")
            .asObservable()
            .subscribe(onNext: {[weak self] data in
            guard let self = self,
                  let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                self.viewModel.payments = data.pagos ?? []
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    func configureTransactionDropDown() {
        let dropDown = DropDown()
        dropDown.anchorView = modifyItemsButton
        dropDown.dataSource = viewModel.transactionsNumber.map { "\($0)" }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            actualTransactionNumber = Int(item) ?? 10
            numberLabel.text = item
        }
    }

}

// MARK: - Extension Table View
extension TransactionsHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.payments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.viewModel.payments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionHistoryCell") as! TranstactionHistoryTableViewCell

        cell.setHistoryData(with: data)
        cell.selectionStyle = .none

        return cell
    }
}
