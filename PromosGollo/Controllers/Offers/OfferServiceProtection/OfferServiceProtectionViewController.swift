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

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 80)
        collectionView.collectionViewLayout = layout

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
            selected.titleLabel.textColor = .white
            selected.cellView.backgroundColor = .primaryLight
            selected.cellView.layer.masksToBounds = true

            let previous = collectionView.cellForItem(at: lastIndexActive) as? OfferServiceProtectionCollectionViewCell
            previous?.titleLabel.textColor = UIColor { tc in
                switch tc.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            }
            previous?.cellView.backgroundColor = .white
            previous?.cellView.layer.masksToBounds = true

            self.selectedWarranty = services[indexPath.row]
            self.lastIndexActive = indexPath
        }
    }
}

extension OfferServiceProtectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  25
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: 80)
    }
}
