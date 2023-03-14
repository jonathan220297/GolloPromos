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
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    lazy var viewModel: NotificationsViewModel = {
        return NotificationsViewModel()
    }()
    var fromNotifications: Bool = false
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notificaciones"
        self.tableView.rowHeight = 75.0
        fetchNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        if fromNotifications {
            backView.isHidden = false
        } else {
            backView.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
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
        
        backButton
            .rx
            .tap
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
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
                self.viewModel.NotificationsArray = data
                if data.isEmpty {
                    self.emptyView.alpha = 1
                    self.dataView.alpha = 0
                } else {
                    self.emptyView.alpha = 0
                    self.dataView.alpha = 1
                }
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    func markAsRead(with notificationId: String) {
        viewModel
            .markAsRead(with: notificationId)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let _ = data else { return }
                self.fetchNotifications()
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
        self.markAsRead(with: self.viewModel.NotificationsArray[indexPath.row].IdNotification ?? "")
        if self.viewModel.NotificationsArray[indexPath.row].type == "3" {
            let orderDetailTabViewController = OrderDetailTabViewController(
                viewModel: OrderDetailTabViewModel(),
                orderId: String(self.viewModel.NotificationsArray[indexPath.row].idType ?? 0),
                fromNotifications: false
            )
            orderDetailTabViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(orderDetailTabViewController, animated: true)
        } else {
            let n = self.self.viewModel.NotificationsArray[indexPath.row]
            let vc = NotificationDetailViewController.instantiate(fromAppStoryboard: .Notifications)
            vc.modalPresentationStyle = .fullScreen
            vc.notification = n
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if !viewModel.fetchingMore {
                viewModel.fetchingMore = true
                viewModel.page += 1
                //fetchNotifications()
            }
        }
    }
}
