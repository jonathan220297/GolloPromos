//
//  OffersFilteredListViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 11/10/22.
//

import UIKit
import RxSwift

class OffersFilteredListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    // MARK: - Constants
    let viewModel: OffersFilteredListViewModel
    let bag = DisposeBag()

    // MARK: - Variables
    var lastIndexActive: IndexPath = [1, 0]

    // MARK: - Lifecycle
    init(viewModel: OffersFilteredListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "OffersFilteredListViewController", bundle: nil)
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
        fetchCategories()
        fetchOffers()
    }

    // MARK: - Functions
    func configureTableView() {
        self.collectionView.register(UINib(nibName: "CategoriesFilteredListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesFilteredListCell")
        self.tableView.register(UINib(nibName: "OffersTableViewCell", bundle: nil), forCellReuseIdentifier: "OffersTableViewCell")
    }

    fileprivate func fetchCategories() {
        view.activityStarAnimating()
        viewModel.fetchFilteredCategories()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimating()
                self.viewModel.categories = data
                self.collectionView.reloadData()
            })
            .disposed(by: bag)
    }

    fileprivate func fetchOffers() {
        viewModel
            .fetchFilteredProducts()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    self.viewModel.products = data
                    self.tableView.reloadData()
                }
            })
            .disposed(by: bag)
    }

}

extension OffersFilteredListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesFilteredListCell", for: indexPath) as! CategoriesFilteredListCollectionViewCell
        cell.titleLabel.text = viewModel.categories[indexPath.row].nombre
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.lastIndexActive != indexPath {
            let selected = collectionView.cellForItem(at: indexPath) as! CategoriesFilteredListCollectionViewCell
            selected.titleLabel.textColor = .white
            selected.cellView.backgroundColor = .primaryLight
            selected.cellView.layer.cornerRadius = 10
            selected.cellView.layer.masksToBounds = true
            selected.cellView.layoutSubviews()

            let previous = collectionView.cellForItem(at: lastIndexActive) as? CategoriesFilteredListCollectionViewCell
            previous?.titleLabel.textColor = UIColor { tc in
                switch tc.userInterfaceStyle {
                case .dark:
                    return UIColor.primary
                default:
                    return UIColor.white
                }
            }
            previous?.cellView.backgroundColor = .primary
            selected.cellView.layer.cornerRadius = 10
            selected.cellView.layer.masksToBounds = true
            selected.cellView.layoutSubviews()

            self.lastIndexActive = indexPath
        }
    }
}

extension OffersFilteredListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count > 0 ? 1 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getOfferCell(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.products.count > 2 ? 650 : 320
    }

    func getOfferCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OffersTableViewCell", for: indexPath) as? OffersTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.viewModel.offersArray = viewModel.products
        cell.configureCollectionView()
        return cell
    }
}

extension OffersFilteredListViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
