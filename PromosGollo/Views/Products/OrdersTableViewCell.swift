//
//  OrdersTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {

    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    func setOrderData(with data: Order) {
        referenceLabel.attributedText = formatHTML(header: "Número de referencia: ", content: "\(data.idOrden ?? 0)")
        orderNumberLabel.attributedText = formatHTML(header: "Número de order: ", content: data.ordenNaf ?? "")
        statusLabel.attributedText = formatHTML(header: "Status: ", content: "Ingresado")
        if let date = data.fechaOrden {
            dateLabel.attributedText = formatHTML(header: "Fecha pedido: ", content: date.convertDateFormater(with: "MMMM dd, yyyy"))
        }
    }
}
