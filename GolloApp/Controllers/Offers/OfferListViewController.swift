//
//  HomeViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import RxSwift

class OfferListViewController: UIViewController {

    @IBOutlet weak var filterLabel: UILabel!

    lazy var viewModel: OffersListViewModel = {
        return OffersListViewModel()
    }()
    let bag = DisposeBag()

    var filterTitle: String = ""
    var category: CategoriesData? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        fetchOffersList()
    }

    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchOffersList() {
        viewModel.fetchOffersList(category: String(category?.idTipoCategoriaApp ?? 0), store: nil, page: 1, query: nil)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.offers = data
            })
            .disposed(by: bag)
    }

}
