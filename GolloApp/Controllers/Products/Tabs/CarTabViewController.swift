//
//  CarTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import FirebaseAuth
import RxSwift
import UIKit

class CarTabViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var carTableView: UITableView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var endOrderButton: UIButton!
    @IBOutlet weak var emptyCarButton: UIButton!
    @IBOutlet weak var emptyView: UIView!

    // MARK: - Constants
    let viewModel: CarTabViewModel
    let bag = DisposeBag()
    
    // MARK: - Lifecycle
    init(viewModel: CarTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CarTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Mi carrito"
        navigationItem.hidesBackButton = false
        navigationController?.navigationBar.tintColor = .white
        configureViews()
        configureTableView()
        configureRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        fetchCarItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Functions
    func configureViews() {
        endOrderButton.layer.cornerRadius = 10.0
    }
    
    func configureTableView() {
        carTableView.register(
            UINib(
                nibName: "CarProductTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "CarProductTableViewCell"
        )
    }
    
    func configureRx() {
        endOrderButton
            .rx
            .tap
            .subscribe(onNext: {
                if Auth.auth().currentUser != nil {
                    self.checkIfUserRegistered()
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
                    let loginVC = vc.viewControllers.first as? LoginViewController
                    loginVC?.delegate = self
                    self.present(vc, animated: true)
                }
            })
            .disposed(by: bag)
        
        emptyCarButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if CoreDataService().deleteAllItems() {
                    self.viewModel.car.removeAll()
                    self.carTableView.reloadData()
                    self.emptyView.alpha = 1
                }
            })
            .disposed(by: bag)
    }
    
    func fetchCarItems() {
        viewModel.car = CoreDataService().fetchCarItems()

        if viewModel.car.isEmpty {
            self.emptyView.alpha = 1
        } else {
            self.emptyView.alpha = 0
        }

        carTableView.reloadData()
        var totalString = "Tiene \(viewModel.car.count) item(s) en el carrito"
        if viewModel.car.count > 1 {
            totalString = "Tiene \(viewModel.car.count) items en el carrito"
        } else {
            totalString = "Tiene \(viewModel.car.count) item en el carrito"
        }

        totalItemsLabel.text = totalString
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        var total = 0.0
        var carBonus = 0.0
        for item in viewModel.car {
            var totalPrice = 0.0
            var totalBonus = 0.0
            if let bonus = item.montoBonoProveedor {
                totalBonus = bonus
                totalPrice = item.precioUnitario - item.montoDescuento - bonus
            } else {
                totalPrice = item.precioUnitario - item.montoDescuento
            }
            carBonus += (totalBonus * Double(item.cantidad))
            total += (totalPrice * Double(item.cantidad)) + (item.montoExtragar * Double(item.cantidad))
        }
        viewModel.total = total
        viewModel.bonus = carBonus
        totalLabel.text = "₡" + numberFormatter.string(from: NSNumber(value: total))!
    }
    
    func checkIfUserRegistered() {
        if Variables.isRegisterUser {
            self.viewModel.carManager.emptyCarWithCoreData()
            self.viewModel.setItemsToCarManager()
            self.viewModel.carManager.total = self.viewModel.total
            self.viewModel.carManager.bonus = self.viewModel.bonus
            let paymentAddressViewController = PaymentAddressViewController(
                viewModel: PaymentAddressViewModel()
            )
            paymentAddressViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(paymentAddressViewController, animated: true)
        } else {
            let editProfileViewController = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
            editProfileViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(editProfileViewController, animated: true)
        }
    }
}

extension CarTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.car.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCarProductCell(tableView, cellForRowAt: indexPath)
    }
    
    func getCarProductCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarProductTableViewCell", for: indexPath) as? CarProductTableViewCell else {
            return UITableViewCell()
        }
        cell.setProductData(with: viewModel.car[indexPath.row])
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }
}

extension CarTabViewController: CarProductDelegate {
    func deleteItem(at indexPath: IndexPath) {
        guard let id = viewModel.car[indexPath.row].idCarItem else { return }
        if CoreDataService().deleteCarItem(with: id) {
            fetchCarItems()
        }
    }
    
    func updateQuantity(at indexPath: IndexPath, _ quantity: Int) {
        guard let id = viewModel.car[indexPath.row].idCarItem else { return }
        if CoreDataService().updateProductQuantity(for: id, quantity) {
            fetchCarItems()
        }
    }

    func addGolloPlus(at indexPath: IndexPath) {
        guard let id = viewModel.car[indexPath.row].idCarItem else { return }
        let warranties = CoreDataService().fetchCarWarranty(with: id)
        let sorted = warranties.sorted { $0.plazoMeses ?? 0 < $1.plazoMeses ?? 0 }
        let offerServiceProtectionViewController = OfferServiceProtectionViewController(services: sorted)
        offerServiceProtectionViewController.delegate = self
        offerServiceProtectionViewController.selectedId = id
        offerServiceProtectionViewController.modalPresentationStyle = .overCurrentContext
        offerServiceProtectionViewController.modalTransitionStyle = .crossDissolve
        self.present(offerServiceProtectionViewController, animated: true)
    }

    func removeGolloPlus(at indexPath: IndexPath) {
        guard let id = viewModel.car[indexPath.row].idCarItem else { return }
        if CoreDataService().removeGolloPlus(for: id) {
            fetchCarItems()
        }
    }
}

extension CarTabViewController: OfferServiceProtectionDelegate {
    func protectionSelected(with id: UUID, month: Int, amount: Double) {
        if CoreDataService().addGolloPlus(for: id, month: month, amount: amount) {
            fetchCarItems()
        } else {
            showAlert(alertText: "GolloApp", alertMessage: "Intentelo de nuevo.")
        }
    }
}

extension CarTabViewController: LoginDelegate {
    func loginViewControllerShouldDismiss(_ loginViewController: LoginViewController) { }
    
    func didLoginSucceed() {
        checkIfUserRegistered()
    }
}
