//
//  GolloStoresTableViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 19/5/23.
//

import UIKit

class GolloStoresTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Functions
    func setShopData(with data: ShopData) {
        self.storeNameLabel.text = data.nombre
        self.storeAddressLabel.text = data.direccion
    }
}
