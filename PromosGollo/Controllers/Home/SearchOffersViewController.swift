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
    }

}
