//
//  ThirdPartyAccountTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 22/10/21.
//

import UIKit

protocol ThirdPartyAccountsDelegate {
    func PayAccount(with index: Int)
}

class ThirdPartyAccountsTableViewCell: UITableViewCell {

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!

    var delegate: ThirdPartyAccountsDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setAccount(model: AccountsDetail, index: Int) {
        self.paymentButton.tag = index

        accountLabel.text = "Número de cuenta: \(model.numCuenta ?? "")"

        if let date = model.fechaPago {
            paymentDateLabel.text = date.formatStringDateGollo()
        }

        if let fee = numberFormatter.string(from: NSNumber(value: model.montoCuota ?? 0.0)) {
            feeAmountLabel.text = "₡" + String(fee)
        }
    }

    @IBAction func paymentButtonTapped(_ sender: UIButton) {
        delegate.PayAccount(with: sender.tag)
    }

}
