//
//  MenuTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/9/22.
//

import UIKit

class MenuTabTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setMenuData(with data: ItemTabData) {
        itemImageView.image = UIImage(named: data.image)
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
    }

}
