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
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.delegate?.deleteItem(at: self.indexPath)
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
    }
    
    func configureRx() {
        addWarrantyButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.deleteItem(at: self.indexPath)
            })
            .disposed(by: bag)
    }
}
