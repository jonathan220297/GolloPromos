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
        orderNumberLabel.attributedText = formatHTML(header: "Número de orden: ", content: data.ordenNaf ?? "")
        statusLabel.attributedText = formatHTML(header: "Estado: ", content: data.descripcionCupon ?? "")
        if let date = data.fechaOrden {
            dateLabel.attributedText = formatHTML(header: "Fecha pedido: ", content: date.formatStringDateGollo())
        }
        referenceLabel.attributedText = formatHTML(header: "Referencia: ", content: "\(data.idOrden ?? "")")
    }
}
