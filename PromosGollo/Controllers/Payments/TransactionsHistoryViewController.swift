//
//  TransactionsHistoryViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/8/22.
//

import UIKit
import RxSwift
import RxCocoa

class TransactionsHistoryViewController: UIViewController {

    lazy var viewModel: TransactionsHistoryViewModel = {
        return TransactionsHistoryViewModel()
    }()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
