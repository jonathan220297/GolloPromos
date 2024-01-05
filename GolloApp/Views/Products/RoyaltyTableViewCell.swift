//
//  RoyaltyTableViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 3/11/22.
//

import UIKit

class RoyaltyTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
