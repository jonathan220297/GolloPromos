//
//  SectionCollectionViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import RxSwift
import UIKit

protocol HomeSectionDelegate: AnyObject {
    func moreButtonTapped(at indexPath: IndexPath)
}

class SectionCollectionViewCell: UICollectionReusableView {
    @IBOutlet weak var upperDividerView: UIView!
    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var indexPath = IndexPath(row: 0, section: 0)
    var delegate: HomeSectionDelegate?
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
    }

    // MARK: - Functions
    func setSectionName(with text: String) {
        sectionNameLabel.text = text
    }
    
    func configureRx() {
        moreButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.moreButtonTapped(at: self.indexPath)
            })
            .disposed(by: bag)
    }
}
