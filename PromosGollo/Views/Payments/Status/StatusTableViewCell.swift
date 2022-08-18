//
//  StatusTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import UIKit

protocol StatusDelegate {
    func OpenItems(with index: Int)
}

class StatusTableViewCell: UITableViewCell {

    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var itemsButton: UIButton!
    @IBOutlet weak var initialAmountLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet weak var amountArrearsLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var dayArrearsLabel: UILabel!

    var delegate: StatusDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setStatus(model: AccountData, index: Int) {
        accountTypeLabel.text = model.tipoCuenta
        accountLabel.text = "Número de cuenta: \(model.numCuenta ?? "")"
        startDateLabel.text = "Fecha de inicio: \(model.fecha ?? "")"
        if let initial = numberFormatter.string(from: NSNumber(value: model.montoInicial ?? 0.0)) {
            initialAmountLabel.text = "₡" + String(initial)
        }
        if let current = numberFormatter.string(from: NSNumber(value: model.saldoActual ?? 0.0)) {
            currentAmountLabel.text = "₡" + String(current)
        }
        if let total = numberFormatter.string(from: NSNumber(value: model.montoCancelarCuenta ?? 0.0)) {
            totalPaymentLabel.text = "₡" + String(total)
        }

        paymentDateLabel.text = model.fechaPago
        if let fee = numberFormatter.string(from: NSNumber(value: model.montoPago ?? 0.0)) {
            feeAmountLabel.text = "₡" + String(fee)
        }
        if let arrears = numberFormatter.string(from: NSNumber(value: model.montoMora ?? 0.0)) {
            amountArrearsLabel.text = "₡" + String(arrears)
        }

        itemsButton.addTarget(self, action: #selector(itemsButtonTapped(_:)), for: .touchUpInside)
        itemsButton.tag = index
    }

    @IBAction func itemsButtonTapped(_ sender: UIButton) {
        delegate.OpenItems(with: sender.tag)
    }
}
