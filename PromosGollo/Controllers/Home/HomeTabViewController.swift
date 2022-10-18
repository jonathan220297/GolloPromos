//
//  HomeTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import RxSwift
import UIKit

class HomeTabViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    // MARK: - Constants
    let viewModel: HomeViewModel
    let disposeBag = DisposeBag()
    let userDefaults = UserDefaults.standard
    
    // MARK: - Lifecycle
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomeTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureCollectionView()
        configureViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHomeConfiguration()
    }
    
    // MARK: - Observers
    @objc func handleMoreTap(_ sender: UIGestureRecognizer) {
    }
    
    // MARK: - Functions
    fileprivate func configureViewModel() {
        viewModel.reloadTableViewData = { [weak self] in
            guard let self = self else { return }
            self.viewModel.sections.sort { section1, section2 in
                guard let position1 = section1.position,
                      let position2 = section2.position else { return false }
                return position1 < position2
            }
            self.homeCollectionView.reloadData()
        }
    }
    
    fileprivate func configureCollectionView() {
        homeCollectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        homeCollectionView.register(UINib(nibName: "SectionCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionCollectionViewCell")
        homeCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        
    }
    
    fileprivate func fetchHomeConfiguration() {
        view.activityStarAnimating()
        viewModel
            .getHomeConfiguration()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                DispatchQueue.main.async {
                    defer { self.view.activityStopAnimating() }
                    self.viewModel.configuration = response
                    self.viewModel.configureSections()
                    self.homeCollectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension HomeTabViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.sections[section].banner != nil {
            return 1
        } else if let products = viewModel.sections[section].product {
            return products.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionCollectionViewCell", for: indexPath) as! SectionCollectionViewCell
        
        header.indexPath = indexPath
        header.setSectionName(with: viewModel.sections[indexPath.section].name ?? "")
        header.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.sections[section].banner != nil {
            return CGSize(width: collectionView.bounds.width, height: 0)
        } else if let products = viewModel.sections[section].product, !products.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 50)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.sections[indexPath.section].banner != nil {
            return getBannerCell(collectionView, cellForItemAt: indexPath)
        } else if viewModel.sections[indexPath.section].product != nil {
            return getProductCell(collectionView, cellForItemAt: indexPath)
        } else {
            return UICollectionViewCell()
        }
    }
    
    func getBannerCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell else { return UICollectionViewCell() }
        cell.setBanner(with: viewModel.sections[indexPath.section].banner)
        return cell
    }
    
    func getProductCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        cell.setProductData(with: viewModel.sections[indexPath.section].product?[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.sections[indexPath.section].banner != nil {
            let height = viewModel.sections[indexPath.section].height ?? 100.0
            return CGSize(width: collectionView.frame.size.width, height: Double(height))
        } else {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 300)
        }
    }
}

extension HomeTabViewController: UICollectionViewDelegate {
    
}

extension HomeTabViewController: HomeSectionDelegate {
    func moreButtonTapped(at indexPath: IndexPath) {
        let offersFilteredListViewController = OffersFilteredListViewController(
            viewModel: OffersFilteredListViewModel(),
            category: viewModel.sections[indexPath.section].link,
            taxonomy: -1
        )
        offersFilteredListViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
    }
}

extension HomeTabViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeTabViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
