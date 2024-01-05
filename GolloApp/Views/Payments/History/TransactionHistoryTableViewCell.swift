//
//  TransactionHistoryTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/22.
//

import UIKit

class TranstactionHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var debtLabel: UILabel!
    @IBOutlet weak var assistanceLabel: UILabel!
    @IBOutlet weak var assistanceNumberLabel: UILabel!
    @IBOutlet weak var taxesLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setHistoryData(with data: Payments) {
        accountNumberLabel.text = "No. \(data.noFisico ?? "")"
        dateLabel.text = data.fecha?.formatStringDateGollo()
        if let capital = numberFormatter.string(from: NSNumber(value: data.monPagoCapital ?? 0)) {
            capitalLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(capital)"
        }
        if let interes = numberFormatter.string(from: NSNumber(value: data.monPagoInteres ?? 0)) {
            interestLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(interes)"
        }
        if let debt = numberFormatter.string(from: NSNumber(value: data.monPagoMora ?? 0)) {
            debtLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(debt)"
        }
        if let assistance = numberFormatter.string(from: NSNumber(value: data.monCuotaAsistencia ?? 0)) {
            assistanceLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(assistance)"
        }
        assistanceNumberLabel.text = data.noCuotaAsistencia
        if let taxes = numberFormatter.string(from: NSNumber(value: data.montTotImpuesto ?? 0)) {
            taxesLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(taxes)"
        }
        if let amount = numberFormatter.string(from: NSNumber(value: data.montoRecibo ?? 0)) {
            amountLabel.text = "Monto: \(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(amount)"
        }
    }
    
}
