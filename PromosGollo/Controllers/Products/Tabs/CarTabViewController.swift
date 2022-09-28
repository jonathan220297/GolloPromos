//
//  CarTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import RxSwift
import UIKit

class CarTabViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var carTableView: UITableView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var endOrderButton: UIButton!
    @IBOutlet weak var emptyCarButton: UIButton!
    
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
        tabBarController?.navigationItem.title = "Car"
        configureViews()
        configureTableView()
        configureRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.navigationBar.isHidden = true
        fetchCarItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationController?.navigationBar.isHidden = false
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
                self.viewModel.setItemsToCarManager()
                self.viewModel.carManager.total = self.viewModel.total
                let paymentAddressViewController = PaymentAddressViewController(
                    viewModel: PaymentAddressViewModel()
                )
                paymentAddressViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(paymentAddressViewController, animated: true)
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
                }
            })
            .disposed(by: bag)
    }
    
    func fetchCarItems() {
        viewModel.car = CoreDataService().fetchCarItems()
        carTableView.reloadData()
        totalItemsLabel.text = "Tienes \(viewModel.car.count) item(s) en el carrito"
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        var total = 0.0
        for item in viewModel.car {
            total += (item.precioUnitario * Double(item.cantidad))
        }
        viewModel.total = total
        totalLabel.text = "₡" + formatter.string(from: NSNumber(value: total))!
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
}
