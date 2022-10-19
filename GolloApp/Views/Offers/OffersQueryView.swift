//
//  OffersQueryView.swift
//  PromosGollo
//
//  Created by Jonathan  Rodriguez on 29/10/21.
//

import UIKit
import DropDown
import Nuke

class OffersQueryView: DropDownCell {
    @IBOutlet weak var offersImageView: UIImageView!
    @IBOutlet weak var offersSku: UILabel!
    
    func setData(with image: String,
                 _ sku: String) {
        if let url = URL(string: image) {
            Nuke.loadImage(with: url, into: offersImageView)
        }
        offersSku.text = sku
    }
}
