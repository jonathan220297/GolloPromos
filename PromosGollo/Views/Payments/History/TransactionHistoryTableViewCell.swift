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
        dateLabel.text = data.fecha
        capitalLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(data.monPagoCapital ?? 0)"
        interestLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(data.monPagoInteres ?? 0)"
        debtLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(data.monPagoMora ?? 0)"
        assistanceLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(data.monCuotaAsistencia ?? 0)"
        assistanceNumberLabel.text = data.noCuotaAsistencia
        taxesLabel.text = "\(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(data.montTotImpuesto ?? 0)"
        amountLabel.text = "Monto: \(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(data.montoRecibo ?? 0)"
    }
    
}
