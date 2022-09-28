//
//  OfferServiceProtectionViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 16/9/22.
//

import RxSwift
import UIKit

class OfferServiceProtectionViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addServiceProtectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    let bag = DisposeBag()
    var services: [Warranty] = []
    var selectedWarranty: Warranty?

    var lastIndexActive: IndexPath = [1, 0]

    // MARK: - Lifecycle
    init(services: [Warranty]) {
        self.services = services
        super.init(nibName: "OfferServiceProtectionViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()

        let cell = UINib(nibName: "OfferServiceProtectionCollectionViewCell", bundle: nil)
        collectionView.register(cell, forCellWithReuseIdentifier: "offerServiceProtectionCell")
    }

    
    // MARK: - Functions
    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
}

extension OfferServiceProtectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "offerServiceProtectionCell", for: indexPath) as! OfferServiceProtectionCollectionViewCell
        cell.titleLabel.text = services[indexPath.row].titulo
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.lastIndexActive != indexPath {
            let selected = collectionView.cellForItem(at: indexPath) as! OfferServiceProtectionCollectionViewCell
            selected.cellView.backgroundColor = .primaryLight
            selected.cellView.layer.masksToBounds = true

            let previous = collectionView.cellForItem(at: lastIndexActive) as? OfferServiceProtectionCollectionViewCell
            previous?.cellView.backgroundColor = .white
            previous?.cellView.layer.masksToBounds = true

            self.selectedWarranty = services[indexPath.row]
            self.lastIndexActive = indexPath
        }
    }
}
