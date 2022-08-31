//
//  HistoryPaymentTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/22.
//

import UIKit

class HistoryPaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var successPaymentImageView: UIImageView!
    @IBOutlet weak var tarsnactionIDLabel: UILabel!
    @IBOutlet weak var storeIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setHistoryData(with data: AppTransaction) {
        paymentTypeLabel.text = getMovementType(type: data.tipoMovimiento)
        tarsnactionIDLabel.text = data.numeroDocAplicado
        storeIDLabel.text = data.idTienda
        dateLabel.text = data.fecha
        clientNameLabel.text = data.nombreCliente
        messageLabel.text = data.mensajeEnvio
        if let amount = numberFormatter.string(from: NSNumber(value: data.monto ?? 0.0)) {
            amountLabel.text = "Monto: \(GOLLOAPP.CURRENCY_SIMBOL.rawValue) \(amount)"
        }

        if data.procesada?.bool ?? false {
            successPaymentImageView.alpha = 1
            messageStackView.alpha = 0
        } else {
            successPaymentImageView.alpha = 0
            messageLabel.textColor = UIColor.red
        }
    }

    fileprivate func getMovementType(type: String?) -> String {
        if type == "C" {
            return "PAGO DE CUOTA"
        } else if type == "OC" {
            return "COMPRA"
        } else {
            return ""
        }
    }
}
