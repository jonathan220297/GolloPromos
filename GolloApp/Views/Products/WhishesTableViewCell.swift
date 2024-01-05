//
//  WhishesTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/9/22.
//

import UIKit

protocol WhishesDelegate: AnyObject {
    func deleteItem(at indexPath: IndexPath)
}

class WhishesTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!

    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    weak var delegate: WhishesDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteProduct(_ sender: Any) {
        delegate?.deleteItem(at: self.indexPath)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
