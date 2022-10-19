//
//  ShippingMethodTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import UIKit

protocol ShippingMethodCellDelegate: AnyObject {
    func didSelectMethod(at indexPath: IndexPath)
}

class ShippingMethodTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var shippingNameLabel: UILabel!
    @IBOutlet weak var shippingDescriptionLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    
    weak var delegate: ShippingMethodCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions
    @IBAction func checkBoxButtonTapped(_ sender: Any) {
        self.delegate?.didSelectMethod(at: indexPath)
    }
    
    // MARK: - Functions
    func setMethodData(with data: ShippingMethodData) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        shippingNameLabel.text = data.shippingType
        shippingDescriptionLabel.text = data.shippingDescription
        shippingCostLabel.text = "₡" + formatter.string(from: NSNumber(value: data.cost))!
        checkBoxButton.setImage(
            UIImage(
                named: data.selected ? "ic_radio-button-checked" : "ic_radio-button-unchecked"
            ),
            for: .normal
        )
    }
}
