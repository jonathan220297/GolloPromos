//
//  HeaderTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(model: ParentModel) {
        switch model.code {
        case OFFER_TYPE.COMING.rawValue:
            iconImage.image = UIImage(named: "ic_proximas_promociones")
        case OFFER_TYPE.NEW.rawValue:
            iconImage.image = UIImage(named: "ic_nuevas_promociones")
        case OFFER_TYPE.PRICE_CHANGE.rawValue:
            iconImage.image = UIImage(named: "ic_cambio_precio")
        case OFFER_TYPE.INACTIVE.rawValue:
            iconImage.image = UIImage(named: "ic_promociones_inactivas")
        case OFFER_TYPE.NONE.rawValue:
            iconImage.image = UIImage(named: "ic_otras_promociones")
        default:
            print("Default")
        }

        titleLable.text = model.name
    }

}
