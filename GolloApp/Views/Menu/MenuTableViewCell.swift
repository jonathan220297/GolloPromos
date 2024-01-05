//
//  MenuTableViewCell.swift
//  Shoppi
//
//  Created by Jonathan  Rodriguez on 9/7/21.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var optionMenuImageView: UIImageView!
    @IBOutlet weak var optionMenuLabel: UILabel!
    @IBOutlet weak var optionSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with menu: Menu) {
        optionMenuImageView.image = UIImage(named: menu.image)
        optionMenuLabel.text = menu.title
        optionSubtitleLabel.text = menu.subtitle
    }
}
