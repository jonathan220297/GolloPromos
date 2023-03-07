//
//  EmmaTermsTableViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 7/3/23.
//

import RxSwift
import UIKit

protocol EmmaTermsCellDelegate: AnyObject {
    func didSelectEmmaOption(at indexPath: IndexPath)
}

class EmmaTermsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dataContentView: UIView!
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var monthsLabel: UILabel!
    @IBOutlet weak var baseAmountLabel: UILabel!
    @IBOutlet weak var taxesAmountLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tasaEfectivaLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var monthlyAmountLabel: UILabel!
    
    weak var delegate: EmmaTermsCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)
    let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setMethodData(with item: EmmaTerms) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        dataContentView.backgroundColor = item.selected ?? false ? UIColor.primaryLight : UIColor.white
        monthsLabel.text = "\(item.cantidadMeses ?? 0) meses"
        baseAmountLabel.text = "₡" + (formatter.string(from: NSNumber(value: item.montoBase ?? 0.0)) ?? "0.0")
        taxesAmountLabel.text = "₡" + (formatter.string(from: NSNumber(value: item.montoIntereses ?? 0.0)) ?? "0.0")
        yearLabel.text = "₡" + (formatter.string(from: NSNumber(value: item.tasaAnual ?? 0.0)) ?? "0.0")
        tasaEfectivaLabel.text = "₡" + (formatter.string(from: NSNumber(value: item.tasaEfectiva )) ?? "0.0")
        totalAmountLabel.text = "₡" + (formatter.string(from: NSNumber(value: item.montoTotal )) ?? "0.0")
        monthlyAmountLabel.text = "₡" + (formatter.string(from: NSNumber(value: item.montoMensual )) ?? "0.0")
    }
    
    func configureRx() {
        contentButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.didSelectEmmaOption(at: self.indexPath)
            })
            .disposed(by: bag)
    }
    
}
