//
//  GolloStoresViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 19/5/23.
//

import UIKit
import RxSwift
import DropDown

protocol GolloStoresDelegate: AnyObject {
    func storeSelected(with selected: ShopData)
}

class GolloStoresViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Constants
    var viewModel: GolloStoresViewModel
    let bag = DisposeBag()
    var delegate: GolloStoresDelegate?
    
    // MARK: - Lifecycle
    init(viewModel: GolloStoresViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "GolloStoresViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureRx()
        fetchShops()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Functions
    fileprivate func configureTableView() {
        self.tableView.register(
            UINib(
                nibName: "GolloStoresTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "GolloStoresTableViewCell"
        )
        self.tableView.rowHeight = 50.0
        self.tableView.reloadData()
    }
    
    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: bag)

        
        stateButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayStatesList()
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchShops() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchShops()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.view.activityStopAnimatingFull()
                let responseData = response.sorted { $0.nombre < $1.nombre }
                self.viewModel.data = responseData
                self.viewModel.processStates(with: responseData)
                self.viewModel.processShops(with: self.viewModel.states.first ?? "")
                self.stateLabel.text = self.viewModel.states.first ?? ""
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
    
    fileprivate func displayStatesList() {
        let dropDown = DropDown()
        dropDown.anchorView = stateButton
        dropDown.dataSource = viewModel.states
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.stateLabel.text = item
            self.viewModel.stateSelected = item
            self.viewModel.processShops(with: item)
            self.viewModel.shopSelected = self.viewModel.shops.first
            self.tableView.reloadData()
        }
        dropDown.show()
    }

}

extension GolloStoresViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getShopMethodCell(tableView, cellForRowAt: indexPath)
    }
    
    func getShopMethodCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GolloStoresTableViewCell", for: indexPath) as? GolloStoresTableViewCell else {
            return UITableViewCell()
        }
        
        cell.layoutIfNeeded()
        cell.setShopData(with: viewModel.shops[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.storeSelected(with: viewModel.shops[indexPath.row])
        self.dismiss(animated: true)
    }
}
