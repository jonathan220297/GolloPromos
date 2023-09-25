//
//  OptionalExpensesTableViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 12/8/23.
//

import RxSwift
import UIKit

protocol OptionalExpensesCellDelegate: AnyObject {
    func didSelectOptionalExpense(at indexPath: IndexPath)
}

class OptionalExpensesTableViewCell: UITableViewCell {

    @IBOutlet weak var content: UIView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: OptionalExpensesCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
        configureRx()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTaxesData(with data: OtherExpenses) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        let taxPrice = numberFormatter.string(from: NSNumber(value: data.monto ?? 0.0)) ?? ""
        let text = formatHTML(header: "\(data.descripcion ?? ""): ", content: "+\("₡")\(taxPrice)")
        checkBoxButton.setImage(
            UIImage(
                systemName: data.selected ?? false ? "checkmark.square.fill" : "square"
            ),
            for: .normal
        )
        descriptionLabel.attributedText = text
    }
    
    func configureViews() {
        content.backgroundColor = .white
        content.layer.cornerRadius = 8
        content.layer.borderWidth = 1
        content.layer.borderColor = UIColor.gray.cgColor
    }
    
    func configureRx() {
        checkBoxButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.didSelectOptionalExpense(at: self.indexPath)
            })
            .disposed(by: bag)
    }
}
