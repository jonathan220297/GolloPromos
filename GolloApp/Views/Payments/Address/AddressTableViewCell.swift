//
//  AddressTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import UIKit

protocol AddressDelegate: AnyObject {
    func deleteAddress(at indexPath: IndexPath)
}

class AddressTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    
    var indexPath = IndexPath(row: 0, section: 0)
    weak var delegate: AddressDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.deleteAddress(at: indexPath)
    }
    
    // MARK: - Functions
    func setAddressData(with data: UserAddress) {
        addressLabel.text = "Direccion: " + data.direccionExacta
        stateLabel.text = "Provincia: " + data.provinciaDesc
        countyLabel.text = "Cantón: " + data.cantonDesc
        districtLabel.text = "Distrito: " + data.distritoDesc
        postalCodeLabel.text = "Código postal: " + (data.codigoPostal ?? "")
    }
}
