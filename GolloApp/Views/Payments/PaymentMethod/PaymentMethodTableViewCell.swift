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
    func redirectURLPage(at indexPath: IndexPath)
}

class PaymentMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentRadioButton: UIButton!
    @IBOutlet weak var paymentNameLabel: UILabel!
    @IBOutlet weak var paymentDescriptionLabel: UILabel!
    @IBOutlet weak var emmaAmountLabel: UILabel!
    @IBOutlet weak var redirectView: UIView!
    @IBOutlet weak var redirectLinkButton: UIButton!
    
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
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        paymentRadioButton.setImage(
            UIImage(
                named: method.selected ?? false ? "ic_radio-button-checked" : "ic_radio-button-unchecked"
            ),
            for: .normal
        )
        paymentNameLabel.text = method.formaPago
        paymentDescriptionLabel.text = method.descripcion
        if method.indEmma == 1 {
            emmaAmountLabel.isHidden = false
            emmaAmountLabel.text = "Monto disponible: ₡" + (formatter.string(from: NSNumber(value: method.montoDisponibleEmma ?? 0.0)) ?? "0.0")
        } else {
            emmaAmountLabel.isHidden = true
        }
        if let url = method.linkDescarga, !url.isEmpty {
//            redirectLinkButton.setTitle(url.replacingOccurrences(of: "\\", with: ""), for: .normal)
            redirectView.isHidden = false
        } else {
            redirectView.isHidden = true
        }
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
        
        redirectLinkButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.redirectURLPage(at: self.indexPath)
            })
            .disposed(by: bag)
    }
}
