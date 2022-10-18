//
//  NotificationsViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift

class NotificationsViewController: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var heightSearchBar: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel: NotificationsViewModel = {
        return NotificationsViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notifications"
        fetchNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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

    fileprivate func fetchNotifications() {
        viewModel
            .fetchNotifications()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.fetchingMore = false
                if self.viewModel.page == 1 {
                    self.viewModel.NotificationsArray = data
                } else {
                    self.viewModel.NotificationsArray.append(contentsOf: data)
                }
                if data.isEmpty {
                    self.viewModel.page -= 1
                    self.emptyView.alpha = 1
                    self.dataView.alpha = 0
                }
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

}


// MARK: - Extensions
extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.NotificationsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let n = self.viewModel.NotificationsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell

        cell.layoutIfNeeded()
        cell.setNotification(notification: n)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let n = self.self.viewModel.NotificationsArray[indexPath.row]
        let vc = NotificationDetailViewController.instantiate(fromAppStoryboard: .Notifications)
        vc.modalPresentationStyle = .fullScreen
        vc.notification = n
        navigationController?.pushViewController(vc, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if !viewModel.fetchingMore {
                viewModel.fetchingMore = true
                viewModel.page += 1
                fetchNotifications()
            }
        }
    }
}
