//
//  ProductOrderDetailTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 29/9/22.
//

import UIKit
import Nuke

class ProductOrderDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setProductData(with data: OrderDetailInformation) {
        if let url = URL(string: data.urlImagen ?? "") {
            Nuke.loadImage(with: url, into: productImageView)
        }
        titleLabel.text = data.descripcion ?? ""
        subtitleLabel.attributedText = formatHTML(header: "Cantidad: ", content: "\(data.cantidad ?? 0)")
        totalLabel.attributedText = formatHTML(header: "Total: ", content: "₡\(numberFormatter.string(from: NSNumber(value: (data.precioExtendido ?? 0.0))) ?? "")")
    }
    
}
