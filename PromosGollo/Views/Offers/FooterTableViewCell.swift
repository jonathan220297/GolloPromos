//
//  FooterTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import UIKit

class FooterTableViewCell: UITableViewCell {

    // Click
    var cellAction: (() -> Void)? = nil

    @IBOutlet weak var footerButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func showMore(_ sender: Any) {
        print("Click")
        cellAction?()
    }

}

