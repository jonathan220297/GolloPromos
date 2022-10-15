//
//  OffersTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/9/22.
//

import UIKit
import RxSwift

class OffersTabViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var offersTableView: UITableView!
    
    // MARK: - Constants
    let viewModel: OffersTabViewModel
    let bag = DisposeBag()
    
    // MARK: - Lifecycle
    init(viewModel: OffersTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "OffersTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        fetchCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationItem.leftBarButtonItem = nil
    }

    // MARK: - Observers
    @objc func closeButton() {
        dismiss(animated: true)
    }
    
    // MARK: - Functions
    func configureBarButtons() {
        let closeBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButton))
        closeBarButton.tintColor = .white
        tabBarController?.navigationItem.leftBarButtonItem = closeBarButton
    }
    
    func configureTableView() {
        offersTableView.register(UINib(nibName: "CategoryOffersTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryOffersTableViewCell")
        offersTableView.register(UINib(nibName: "OffersTableViewCell", bundle: nil), forCellReuseIdentifier: "OffersTableViewCell")
    }
    
    fileprivate func fetchCategories() {
        view.activityStarAnimating()
        viewModel.fetchCategories()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimating()
                self.viewModel.categories = data
                self.offersTableView.reloadData()
            })
            .disposed(by: bag)
    }

    fileprivate func fetchOffers(with category: String? = nil) {
        viewModel
            .fetchOffers(with: category)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    self.viewModel.processOffers(with: data)
                    self.offersTableView.reloadData()
                }
            })
            .disposed(by: bag)
    }
}

extension OffersTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories[section].productos.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getOfferCell(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.categories[indexPath.section].productos.count > 2 ? 650 : 320
    }
    
    func getOfferCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OffersTableViewCell", for: indexPath) as? OffersTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.viewModel.offersArray = viewModel.categories[indexPath.section].productos
        cell.configureCollectionView()
        return cell
    }
}

extension OffersTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryOffersTableViewCell") as? CategoryOffersTableViewCell else {
            return UIView()
        }
        cell.setCategoryInfo(with: viewModel.categories[section])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension OffersTabViewController: CategoryOffersDelegate {
    func showAllOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldMoveToList indexPath: Int) {
        let offersFilteredListViewController = OffersFilteredListViewController(
            viewModel: OffersFilteredListViewModel(),
            category: indexPath,
            taxonomy: -1
        )
        offersFilteredListViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
    }

    func categoryOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }

    func categoryOffers(_ categoryOffersTableViewCell: CategoryOffersTableViewCell, shouldReloadOffersForCategoryAt indexPath: IndexPath) {
        print("\(indexPath.row) - \(indexPath.section)")
    }
}

extension OffersTabViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
