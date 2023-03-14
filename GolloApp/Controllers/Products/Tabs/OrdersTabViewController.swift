//
//  OrdersTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import UIKit
import RxSwift
import FirebaseAuth
import FirebaseMessaging

class OrdersTabViewController: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var ordersTableView: UITableView!
    
    // MARK: - Constants
    let viewModel: OrdersTabViewModel
    let bag = DisposeBag()
    let userDefaults = UserDefaults.standard

    init(viewModel: OrdersTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "OrdersTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "My orders"
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        fetchOrders()
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationItem.leftBarButtonItem = nil
    }

    // MARK: - Functions
    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .bind { (errorMessage) in
                if !errorMessage.isEmpty {
                    self.emptyView.alpha = 1
                    self.dataView.alpha = 0
                    self.viewModel.errorMessage.accept("")
                }
            }
            .disposed(by: bag)

        viewModel
            .errorExpiredToken
            .asObservable()
            .subscribe(onNext: {[weak self] value in
                guard let self = self,
                      let value = value else { return }
                if value {
                    self.userDefaults.removeObject(forKey: "Information")
                    let _ = KeychainManager.delete(key: "token")
                    Variables.isRegisterUser = false
                    Variables.isLoginUser = false
                    Variables.isClientUser = false
                    Variables.userProfile = nil
                    UserManager.shared.userData = nil
                    self.showAlertWithActions(alertText: "GolloApp", alertMessage: "Tu sesión ha expirado y la aplicación se reiniciara inmediatamente.") {
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            self.userDefaults.removeObject(forKey: "Information")
                            Variables.isRegisterUser = false
                            Variables.isLoginUser = false
                            Variables.isClientUser = false
                            Variables.userProfile = nil
                            UserManager.shared.userData = nil
                            Messaging.messaging().token { token, error in
                              if let error = error {
                                print("Error fetching FCM registration token: \(error)")
                              } else if let token = token {
                                self.registerDevice(with: token)
                              }
                            }
                        } catch let signOutError as NSError {
                            log.error("Error signing out: \(signOutError)")
                        }
                    }
                }
                self.viewModel.errorExpiredToken.accept(nil)
            })
            .disposed(by: bag)
    }

    func configureTableView() {
        ordersTableView.register(UINib(nibName: "OrdersTableViewCell", bundle: nil), forCellReuseIdentifier: "OrdersTableViewCell")
    }

    func fetchOrders() {
        view.activityStarAnimating()
        viewModel.fetchOrders()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let orders = data.ordenes, !orders.isEmpty {
                    self.viewModel.orders = orders
                    self.ordersTableView.reloadData()
                    self.emptyView.alpha = 0
                    self.dataView.alpha = 1
                } else {
                    self.emptyView.alpha = 1
                    self.dataView.alpha = 0
                }
                self.view.activityStopAnimating()
            })
            .disposed(by: bag)
    }

    fileprivate func registerDevice(with token: String) {
        viewModel
            .registerDevice(with: token)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let info = data.registro {
                    Variables.userProfile = info
                    do {
                        try self.userDefaults.setObject(info, forKey: "Information")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if let token = data.token {
                    let _ = self.viewModel.saveToken(with: token)
                }
                if let deviceID = data.idCliente {
                    self.userDefaults.set(deviceID, forKey: "deviceID")
                }
                Variables.isRegisterUser = data.estadoRegistro ?? false
                Variables.isLoginUser = data.estadoLogin ?? false
                Variables.isClientUser = data.estadoCliente ?? false
                self.fetchOrders()
            })
            .disposed(by: bag)
    }
}

extension OrdersTabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getOfferCell(tableView, cellForRowAt: indexPath)
    }

    func getOfferCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersTableViewCell", for: indexPath) as? OrdersTableViewCell else {
            return UITableViewCell()
        }
        cell.setOrderData(with: viewModel.orders[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderDetailTabViewController = OrderDetailTabViewController(
            viewModel: OrderDetailTabViewModel(),
            orderId: String(viewModel.orders[indexPath.row].idOrden ?? 0),
            fromNotifications: false
        )
        orderDetailTabViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(orderDetailTabViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
