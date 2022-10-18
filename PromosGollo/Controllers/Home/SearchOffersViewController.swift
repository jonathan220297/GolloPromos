//
//  SearchOffersViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 14/10/22.
//


import UIKit
import RxSwift
import DropDown

class SearchOffersViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Constants
    let viewModel: SearchOffersViewModel
    let bag = DisposeBag()

    // MARK: - Lifecycle
    init(viewModel: SearchOffersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SearchOffersViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    // MARK: - Functions
    func configureTableView() {
        self.tableView.register(UINib(nibName: "OffersTableViewCell", bundle: nil), forCellReuseIdentifier: "OffersTableViewCell")
    }

    fileprivate func fetchOffers(with searchText: String? = nil) {
        view.activityStarAnimating()
        viewModel
            .fetchFilteredProducts(with: searchText)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimating()
                var products: [Product] = []
                for o in data {
                    let p = Product(
                        productCode: o.productCode,
                        descriptionDetailDescuento: o.descriptionDetailDescuento,
                        descriptionDetailRegalia: o.descriptionDetailRegalia,
                        originalPrice: o.originalPrice,
                        image: o.image,
                        montoBono: o.montoBono,
                        porcDescuento: o.porcDescuento,
                        brand: o.brand,
                        descriptionDetailBono: o.descriptionDetailRegalia,
                        tieneBono: o.tieneBono,
                        name: o.name,
                        modelo: o.modelo,
                        endDate: o.endDate,
                        tieneRegalia: o.tieneRegalia,
                        simboloMoneda: SimboloMoneda.empty,
                        id: o.id,
                        montoDescuento: o.montoDescuento,
                        idUsuario: o.idUsuario,
                        product: o.product,
                        idEmpresa: o.idempresa,
                        startDate: o.startDate,
                        precioFinal: o.precioFinal,
                        productName: o.productName,
                        tieneDescuento: o.tieneDescuento,
                        tipoPromoApp: 0,
                        productoDescription: ""
                    )
                    products.append(p)
                }
                self.viewModel.products = products
                self.tableView.reloadData()

                if data.isEmpty {
                    self.tableView.isHidden = true
                }
            })
            .disposed(by: bag)
    }

}

extension SearchOffersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.tableView.isHidden = true
        } else {
            fetchOffers(with: searchText.lowercased())
        }
    }
}

extension SearchOffersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
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

extension SearchOffersViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

