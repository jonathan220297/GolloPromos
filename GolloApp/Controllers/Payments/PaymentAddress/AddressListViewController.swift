//
//  AddressListViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import RxSwift
import UIKit

protocol AddressListDelegate: AnyObject {
    func didSelectAddress(address: UserAddress)
}

class AddressListViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var addressTableView: UITableView!
    
    // MARK: - Constants
    let viewModel: AddressListViewModel
    let bag = DisposeBag()
    let delegate: AddressListDelegate
    
    // MARK: - Lifecycle
    init(viewModel: AddressListViewModel, delegate: AddressListDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: "AddressListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        fetchAddress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Functions
    func configureTableView() {
        addressTableView.register(
            UINib(
                nibName: "AddressTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "AddressTableViewCell"
        )
    }
    
    func fetchAddress() {
        viewModel
            .fetchAdress()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.viewModel.addressArray = response.direcciones
                self.addressTableView.reloadData()
                if response.direcciones.isEmpty {
                    self.showAlertWithActions(alertText: "GolloApp", alertMessage: "No tienes direcciones guaradas.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            .disposed(by: bag)
    }
    
    func deleteAddress(with addressID: Int) {
        viewModel
            .deleteAddress(with: addressID)
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self else { return }
                self.showAlert(alertText: "Gollo", alertMessage: "Dirección eliminada correctamente")
                self.fetchAddress()
            })
            .disposed(by: bag)
    }
}

extension AddressListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.addressArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getAddressCell(tableView, cellForRowAt: indexPath)
    }
    
    func getAddressCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as? AddressTableViewCell else {
            return UITableViewCell()
        }
        cell.setAddressData(with: viewModel.addressArray[indexPath.row])
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

extension AddressListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true, completion: {
            self.delegate.didSelectAddress(address: self.viewModel.addressArray[indexPath.row])
        })
    }
}

extension AddressListViewController: AddressDelegate {
    func deleteAddress(at indexPath: IndexPath) {
        deleteAddress(with: viewModel.addressArray[indexPath.row].idDireccion)
    }
}
