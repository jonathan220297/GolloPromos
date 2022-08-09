//
//  ProductTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import UIKit
import Nuke

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var porcentajeImageView: UIImageView!
    @IBOutlet weak var regaliaImageView: UIImageView!
    @IBOutlet weak var bonoImageView: UIImageView!

    func setOffers(offer: Offers) {
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )

        titleLabel.text = offer.name
        serialNumberLabel.text = offer.productCode

        if offer.image == "" || offer.image == "NA" {
            productImage.image = UIImage(named: "empty_image")
        } else {
            let url = URL(string: offer.image!)
            if let url = url {
                Nuke.loadImage(with: url, options: options, into: productImage)
            } else {
                productImage.image = UIImage(named: "empty_image")
            }
        }

        if let _ = offer.tieneDescuento {
            porcentajeImageView.image = UIImage(named: "ic_porcentaje")
        } else {
            porcentajeImageView.image = UIImage(named: "ic_porcentaje_gris")
        }

        if let _ = offer.tieneRegalia {
            regaliaImageView.image = UIImage(named: "ic_regalia")
        } else {
            regaliaImageView.image = UIImage(named: "ic_regalia_gris")
        }

        if let _ = offer.tieneBono {
            bonoImageView.image = UIImage(named: "ic_bono")
        } else {
            bonoImageView.image = UIImage(named: "ic_bono_gris")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

