//
//  CategoriesViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import UIKit
import RxSwift

class CategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        fetchCategories()
    }

    fileprivate func fetchCategories() {
        view.activityStartAnimatingFull()
        viewModel.fetchCategoriesFilter()
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
                    catModel.append(CategoryFilteredList(id: 1, count: parent.totalHijos ?? 0, name: parent.nombre ?? "", description: parent.descripcion ?? "", image: "", categories: subsCat))
                }

                self.categories = catModel
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }

}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = categories[section]

        if sections.isOpened {
            return sections.categories.count + 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .primary
        cell.textLabel?.textColor = .white
        
        if indexPath.row == 0 {
            cell.textLabel?.text = categories[indexPath.section].name
        } else {
            cell.textLabel?.text = "\t\(categories[indexPath.section].categories[indexPath.row - 1].name)"
        }

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if categories[indexPath.section].isOpened && indexPath.row > 0 {
            let offersFilteredListViewController = OffersFilteredListViewController(
                viewModel: OffersFilteredListViewModel(),
                category: nil,
                taxonomy: categories[indexPath.section].categories[indexPath.row - 1].id
            )
            offersFilteredListViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
        } else {
            categories[indexPath.section].isOpened = !categories[indexPath.section].isOpened
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
