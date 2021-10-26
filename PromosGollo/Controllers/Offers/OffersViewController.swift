//
//  OffersViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import RxSwift

class OffersViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var offersTableView: UITableView!

    let bag = DisposeBag()

    lazy var viewModel: OffersViewModel = {
        return OffersViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        fetchCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Ofertas"
    }

    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloPromos", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchCategories() {
        viewModel.fetchCategories()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.categories = data
                self.fetchOffers()
            })
            .disposed(by: bag)
    }

    fileprivate func fetchOffers() {
        viewModel.fetchOffers()
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.viewModel.offers = data
            })
            .disposed(by: bag)
    }

}
