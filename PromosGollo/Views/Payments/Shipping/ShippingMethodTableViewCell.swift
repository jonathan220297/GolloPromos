//
//  ShippingMethodTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import UIKit

class ShippingMethodTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var shippingNameLabel: UILabel!
    @IBOutlet weak var shippingDescriptionLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions
    @IBAction func checkBoxButtonTapped(_ sender: Any) {
    }
    
    // MARK: - Functions
    func setMethodData(with data: ShippingMethodData) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        shippingNameLabel.text = data.shippingType
        shippingDescriptionLabel.text = data.shippingDescription
        shippingCostLabel.text = "₡" + formatter.string(from: NSNumber(value: data.cost))!
    }
}
