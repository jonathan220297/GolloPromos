//
//  OffersFooterTableViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 2/8/23.
//

import RxSwift
import UIKit

protocol OffersFooterDelegate: AnyObject {
    func seeMoreTapped(section: Int)
}

class OffersFooterTableViewCell: UITableViewCell {
    @IBOutlet weak var seeMoreButton: UIButton!
    
    var delegate: OffersFooterDelegate?
    
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCategoryInfo(with data: CategoriesData) {
        seeMoreButton
            .rx
            .tap
            .subscribe(onNext: {
                self.delegate?.seeMoreTapped(section: data.idTipoCategoriaApp ?? 0)
            })
            .disposed(by: bag)
    }
}
