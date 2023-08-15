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
    func addGolloPlus(at indexPath: IndexPath)
    func removeGolloPlus(at indexPath: IndexPath)
    func showTaxesDetail(at indexPath: IndexPath)
}

class CarProductTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var deleteItemButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var warrantyStackView: UIStackView!
    @IBOutlet weak var warrantyNameLabel: UILabel!
    @IBOutlet weak var warrantyAmountLabel: UILabel!
    @IBOutlet weak var removeWarrantyButton: UIButton!
    @IBOutlet weak var bonusView: UIStackView!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var addWarrantyView: UIView!
    @IBOutlet weak var addWarrantyButton: UIButton!
    @IBOutlet weak var showExpensesDetailButton: UIButton!
    @IBOutlet weak var showExpensesButton: UIImageView!
    @IBOutlet weak var expensesStackView: UIStackView!
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    weak var delegate: CarProductDelegate?
    let bag = DisposeBag()
    var quantity = 0
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
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
    
    @IBAction func addWarrantyButtonTapped(_ sender: Any) {
        delegate?.addGolloPlus(at: indexPath)
    }
    
    @IBAction func removeWarrantyButtonTapped(_ sender: Any) {
        delegate?.removeGolloPlus(at: indexPath)
    }
    // MARK: - Functions
    private func configureRx() {
        showExpensesDetailButton
            .rx
            .tap
            .bind {
                self.delegate?.showTaxesDetail(at: self.indexPath)
            }
            .disposed(by: bag)
    }
    
    func setProductData(with data: CartItemDetail) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        if let url = URL(string: data.urlImage ?? "") {
            Nuke.loadImage(with: url, options: options, into: productImageView)
        } else {
            productImageView.image = UIImage(named: "empty_image")
        }
        productNameLabel.text = data.descripcion
        productPriceLabel.text = "₡" + numberFormatter.string(from: NSNumber(value: data.precioUnitario))!
        
        if data.montoDescuento > 0.0 {
            discountLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: data.montoDescuento))!)"
        } else {
            discountLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: 0.0))!)"
        }
        
        if let bonus = data.montoBonoProveedor, bonus > 0.0 {
            bonusView.isHidden = false
            bonusLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: bonus))!)"
        } else {
            bonusView.isHidden = true
        }
        
        quantity = data.cantidad
        quantityTextField.text = String(quantity)
        
        var totalPrice = 0.0
        var articlePrice = 0.0
        if let bonus = data.montoBonoProveedor {
            articlePrice = data.precioUnitario - data.montoDescuento - bonus
            totalPrice = data.precioUnitario - data.montoDescuento - bonus
        } else {
            articlePrice = data.precioUnitario - data.montoDescuento
            totalPrice = data.precioUnitario - data.montoDescuento
        }
        totalPrice = totalPrice * Double(data.cantidad)
        
        if let id = data.idCarItem {
            let expenses = CoreDataService().fetchCarExpense(with: id)
            if expenses.count > 0 {
                self.showExpensesButton.isHidden = false
                self.showExpensesDetailButton.isHidden = false
                self.expensesStackView.removeAllArrangedSubviews()
                
                let includesLabel = UILabel()
                includesLabel.font = UIFont.systemFont(ofSize: 11)
                includesLabel.backgroundColor = UIColor.clear
                includesLabel.textColor = .darkGray
                includesLabel.text = "Incluye:"
                
                let articlePriceExpense = OtherExpenses(
                    skuGasto: "",
                    descripcion: "Artículo",
                    monto: articlePrice,
                    obligatorio: -1
                )
                expensesStackView.addArrangedSubview(includesLabel)
                expensesStackView.addArrangedSubview(taxesLabel(with: articlePriceExpense))
                
                expenses.forEach { t in
                    self.expensesStackView.addArrangedSubview(taxesLabel(with: t))
                    totalPrice = totalPrice + ((t.monto ?? 0.0) * Double(data.cantidad))
                }
                
                self.expensesStackView.isHidden = false
            } else {
                self.showExpensesButton.isHidden = true
                self.showExpensesDetailButton.isHidden = true
                self.expensesStackView.isHidden = true
            }
        } else {
            self.showExpensesDetailButton.isHidden = true
            self.showExpensesButton.isHidden = true
            self.expensesStackView.isHidden = true
        }
        
        if data.mesesExtragar != 0 {
            warrantyNameLabel.text = "Gollo plus \(data.mesesExtragar) meses"
            warrantyAmountLabel.text = "₡" + numberFormatter.string(from: NSNumber(value: data.montoExtragar))!
            warrantyStackView.isHidden = false
            addWarrantyView.isHidden = true
            let total = totalPrice + (data.montoExtragar * Double(data.cantidad))
            totalAmountLabel.text = "₡" + numberFormatter.string(from: NSNumber(value: total))!
        } else {
            warrantyStackView.isHidden = true
            if let id = data.idCarItem {
                let warranties = CoreDataService().fetchCarWarranty(with: id)
                if warranties.count > 1 {
                    addWarrantyView.isHidden = false
                } else {
                    addWarrantyView.isHidden = true
                }
            } else {
                addWarrantyView.isHidden = false
            }
            totalAmountLabel.text = "₡" + numberFormatter.string(from: NSNumber(value: totalPrice))!
        }
        
        productPriceLabel.text = "₡" + numberFormatter.string(from: NSNumber(value: totalPrice))!
        
        if data.showingInformation {
            self.expensesStackView.isHidden = false
            self.showExpensesButton.image = UIImage(systemName: "chevron.up")
        } else {
            self.expensesStackView.isHidden = true
            self.showExpensesButton.image = UIImage(systemName: "chevron.down")
        }
    }
    
    private func taxesLabel(with t: OtherExpenses) -> UILabel {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "ic_ok")?.withTintColor(UIColor.systemGreen)
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        let expensesLabel = UILabel()
        expensesLabel.font = UIFont.systemFont(ofSize: 10)
        expensesLabel.backgroundColor = UIColor.clear
        expensesLabel.textColor = .darkGray
        let taxPrice = (numberFormatter.string(from: NSNumber(value: t.monto ?? 0.0)) ?? "").currencyFormatting()
        
        let attributedText = NSMutableAttributedString(attachment: imageAttachment)
        attributedText.append(NSAttributedString(string: " "))
        attributedText.append(NSAttributedString(attributedString: formatHTML(header: "\(t.descripcion ?? ""): ", content: "+\(taxPrice)", size: 10.0)))
        expensesLabel.attributedText = attributedText
        
        return expensesLabel
    }
}
