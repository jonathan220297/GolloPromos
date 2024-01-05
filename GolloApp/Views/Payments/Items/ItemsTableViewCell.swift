//
//  ItemsTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setItem(with model: Items) {
        descriptionLabel.text = "Producto: \(model.descripcion ?? "")"
        if let modelItem = model.modelo, !modelItem.isEmpty {
            modelLabel.isHidden = false
            modelLabel.text = "Modelo: \(modelItem)"
        } else {
            modelLabel.isHidden = true
        }
        quantityLabel.text = "Cantidad: \(model.cantidad ?? 0)"
    }

}

