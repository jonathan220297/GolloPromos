//
//  CarProductTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 20/9/22.
//

import Nuke
import RxSwift
import UIKit

protocol CarProductDelegate: AnyObject {
    func deleteItem(at indexPath: IndexPath)
    func updateQuantity(at indexPath: IndexPath, _ quantity: Int)
}

class CarProductTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var deleteItemButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var warrantyStackView: UIStackView!
    @IBOutlet weak var warrantyNameLabel: UILabel!
    @IBOutlet weak var warrantyAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var addWarrantyView: UIView!
    @IBOutlet weak var addWarrantyButton: UIButton!
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    weak var delegate: CarProductDelegate?
    let bag = DisposeBag()
    var quantity = 0
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.delegate?.deleteItem(at: self.indexPath)
    }
    
    @IBAction func minusButtonTapped(_ sender: Any) {
        if quantity > 1 {
            quantity -= 1
        }
        delegate?.updateQuantity(at: indexPath, quantity)
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        quantity += 1
        delegate?.updateQuantity(at: indexPath, quantity)
    }
    
    // MARK: - Functions
    func setProductData(with data: CartItemDetail) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        if let url = URL(string: data.urlImage ?? "") {
            Nuke.loadImage(with: url, into: productImageView)
        }
        productNameLabel.text = data.descripcion
        productPriceLabel.text = "₡" + formatter.string(from: NSNumber(value: data.precioUnitario))!
        totalAmountLabel.text = "₡" + formatter.string(from: NSNumber(value: data.precioUnitario))!
        quantity = data.cantidad
        quantityTextField.text = String(quantity)
    }
}
