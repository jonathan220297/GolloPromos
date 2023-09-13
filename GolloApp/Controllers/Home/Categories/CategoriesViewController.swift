//
//  CategoriesViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import UIKit
import RxSwift

class CategoriesViewController: UIViewController {
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    // MARK: - Constants
    let viewModel: CategoriesViewModel
    let bag = DisposeBag()
    var categories: [CategoryFilteredList] = []
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CategoriesViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        configureNavBar()
    }
    
    func configureCollectionView() {
        categoriesCollectionView.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoriesCollectionViewCell")
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        categoriesCollectionView.collectionViewLayout = layout
        categoriesCollectionView.reloadData()
    }
    
    fileprivate func fetchCategories() {
        self.view.activityStartAnimatingFull()
        viewModel
            .fetchCategoriesFilter()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimatingFull()
                var catModel: [CategoryFilteredList] = []
                let parentFiltered = data.filter { cat in
                    return cat.parent == 0
                }
                parentFiltered.forEach { parent in
                    let subs = data.filter { sub in
                        return sub.parent == parent.idTipoCategoriaApp
                    }
                    var subsCat: [SubCategoryItem] = []
                    subs.forEach { sb in
                        subsCat.append(SubCategoryItem(id: sb.idTipoCategoriaApp ?? 0, count: sb.totalHijos ?? 0, name: sb.nombre ?? "", description: "\(parent.nombre ?? "") - \(sb.nombre ?? "")", image: ""))
                    }
                    if !subsCat.isEmpty {
                        subsCat.append(SubCategoryItem(id: parent.idTipoCategoriaApp ?? 0, count: parent.totalHijos ?? 0, name: "Todos" , description: "\(parent.nombre ?? "") - Todos", image: ""))
                    }
                    catModel.append(CategoryFilteredList(id: parent.idTipoCategoriaApp ?? 1, count: parent.totalHijos ?? 0, name: parent.nombre ?? "", description: parent.descripcion ?? "", image: "", categories: subsCat))
                }
                
                self.categories = catModel
                self.categoriesCollectionView.reloadData()
            })
            .disposed(by: bag)
    }
}

extension CategoriesViewController: UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getProductCell(collectionView, cellForItemAt: indexPath)
    }
    
    func getProductCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollectionViewCell", for: indexPath) as! CategoriesCollectionViewCell
        cell.setCategoriesData(with: categories[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offersFilteredListViewController = OffersFilteredListViewController(
            viewModel: OffersFilteredListViewModel(),
            category: nil,
            taxonomy: categories[indexPath.row].id
        )
        offersFilteredListViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
    }
}
