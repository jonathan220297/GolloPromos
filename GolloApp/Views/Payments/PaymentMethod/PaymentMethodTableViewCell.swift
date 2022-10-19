//
//  PaymentMethodTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 16/10/22.
//

import RxSwift
import UIKit

protocol PaymentMethodCellDelegate: AnyObject {
    func didSelectPaymentMethod(at indexPath: IndexPath)
}

class PaymentMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentRadioButton: UIButton!
    @IBOutlet weak var paymentNameLabel: UILabel!
    @IBOutlet weak var paymentDescriptionLabel: UILabel!
    
    weak var delegate: PaymentMethodCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setMethodData(with method: PaymentMethodResponse) {
        paymentRadioButton.setImage(
            UIImage(
                named: method.selected ?? false ? "ic_radio-button-checked" : "ic_radio-button-unchecked"
            ),
            for: .normal
        )
        paymentNameLabel.text = method.formaPago
        paymentDescriptionLabel.text = method.descripcion
    }
    
    func configureRx() {
        paymentRadioButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.didSelectPaymentMethod(at: self.indexPath)
            })
            .disposed(by: bag)
    }
}
