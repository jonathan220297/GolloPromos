//
//  HistoryViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {

    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!

    let dateFormatter = DateFormatter()
    let alternativeFormatter = DateFormatter()
    var imagePicker = UIImagePickerController()

    private var datePickerFrom: UIDatePicker?
    private var datePickerTo: UIDatePicker?

    var fromDateSelected: String? = ""
    var toDateSelected: String? = ""

    lazy var viewModel: HistoryViewModel = {
        return HistoryViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Historial de pagos"
        self.tabBarController?.tabBar.isHidden = true

        // Date Picker
        datePickerFrom = UIDatePicker()
        datePickerFrom?.datePickerMode = .date
        datePickerFrom?.locale = .current
        if #available(iOS 14, *) {
            datePickerFrom?.preferredDatePickerStyle = .wheels
            datePickerFrom?.sizeToFit()
        }
        datePickerFrom?.addTarget(self, action: #selector(HistoryViewController.dateChangeFrom(datePicker:)), for: .valueChanged)

        datePickerTo = UIDatePicker()
        datePickerTo?.datePickerMode = .date
        if #available(iOS 14, *) {
            datePickerTo?.preferredDatePickerStyle = .wheels
            datePickerTo?.sizeToFit()
        }
        datePickerTo?.addTarget(self, action: #selector(HistoryViewController.dateChangeTo(datePicker:)), for: .valueChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HistoryViewController.viewTapped(gestureRecognized:)))
        view.addGestureRecognizer(tapGesture)

        fromTextField.inputView = datePickerFrom
        toTextField.inputView = datePickerTo

        self.tableView.rowHeight = 200.0
        hideKeyboardWhenTappedAround()
        configureRx()
        configureDates()
    }

    // MARK: - Observers
    @objc func dateChangeFrom(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        alternativeFormatter.dateFormat = "dd/MM/yyyy"

        fromDateSelected = dateFormatter.string(from: datePicker.date)
        fromTextField.text = alternativeFormatter.string(from: datePicker.date)
    }

    @objc func dateChangeTo(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        DateFormatter().dateFormat = "dd/MM/yyyy"

        toDateSelected = dateFormatter.string(from: datePicker.date)
        toTextField.text = alternativeFormatter.string(from: datePicker.date)
    }

    @objc func viewTapped(gestureRecognized: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func searchHistoryByDate(_ sender: Any) {
        if let from = fromDateSelected,
           let to = toDateSelected {
            if from.isEmpty && to.isEmpty {
                showAlert(alertText: "GolloApp", alertMessage: "Fechas incompletas")
            } else {
                fetchHistory(from: from, to: to)
            }
        } else {
            showAlert(alertText: "GolloApp", alertMessage: "Fechas incompletas")
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

    fileprivate func configureDates() {
        let actualDate = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        alternativeFormatter.dateFormat = "dd/MM/yyyy"

        fromDateSelected = dateFormatter.string(from: actualDate)
        fromTextField.text = alternativeFormatter.string(from: actualDate)

        dateFormatter.dateFormat = "yyyy-MM-dd"
        DateFormatter().dateFormat = "dd/MM/yyyy"

        toDateSelected = dateFormatter.string(from: actualDate)
        toTextField.text = alternativeFormatter.string(from: actualDate)

        if let from = fromDateSelected,
           let to = toDateSelected {
            if !from.isEmpty && !to.isEmpty {
                self.fetchHistory(from: from, to: to)
            }
        }
    }

    fileprivate func fetchHistory(from: String, to: String) {
        view.activityStarAnimating()
        viewModel.fetchHistoryTransactions(with: from, endDate: to)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                if !data.isEmpty {
                    self.viewModel.status = data
                    self.tableView.reloadData()
                    self.emptyView.alpha = 0
                    self.tableView.alpha = 1
                } else {
                    self.emptyView.alpha = 1
                    self.tableView.alpha = 0
                }
            })
            .disposed(by: bag)
    }
}

// MARK: - Extension Table View
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.status.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = self.viewModel.status[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyPaymentCell") as! HistoryPaymentTableViewCell

        cell.setHistoryData(with: history)
        cell.selectionStyle = .none

        return cell
    }
}
