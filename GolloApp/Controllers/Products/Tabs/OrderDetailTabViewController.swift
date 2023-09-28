//
//  OrderDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/9/22.
//

import UIKit
import RxSwift

class OrderDetailTabViewController: UIViewController {

    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var productsLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var deliveryTitleLabel: UILabel!
    @IBOutlet weak var warrantyLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var totalFinalLabel: UILabel!
    @IBOutlet weak var descriptionDeliveryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var quotaStackView: UIStackView!
    @IBOutlet weak var quotaSwitch: UISwitch!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var royaltyView: UIView!
    @IBOutlet weak var royaltyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var royaltyTableView: UITableView!
    @IBOutlet weak var productsView: UIView!
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var productsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var productsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    
    // MARK: - Constants
    let viewModel: OrderDetailTabViewModel
    let orderId: String
    let fromNotifications: Bool
    let bag = DisposeBag()
    let SKU_SHIPPING = "73"
    let SKU_WARRANTY = "4"
    let PAYMENT_BONUS = "90"
    let PAYMENT_METHOD_CARD = "30"

    init(viewModel: OrderDetailTabViewModel, orderId: String, fromNotifications: Bool) {
        self.viewModel = viewModel
        self.orderId = orderId
        self.fromNotifications = fromNotifications
        super.init(nibName: "OrderDetailTabViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detalle de orden"
        configureTableView()
        configureRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchOrderDetail()
        if fromNotifications {
            configureNavigationBar()
        }
    }
    
    // MARK: - Observers
    @objc func closeTapped() {
        dismiss(animated: true)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .primary
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }

    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.showAlertWithActions(alertText: "GolloApp", alertMessage: error) {
                        if self.fromNotifications {
                            self.dismiss(animated: true)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)
    }

    func configureTableView() {
        royaltyTableView.register(UINib(nibName: "RoyaltyTableViewCell", bundle: nil), forCellReuseIdentifier: "RoyaltyTableViewCell")
        productsTableView.register(UINib(nibName: "ProductOrderDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductOrderDetailTableViewCell")
    }

    func fetchOrderDetail() {
        view.activityStartAnimatingFull()
        viewModel.fetchOrderDetail(orderId: orderId)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimatingFull()
                self.showData(with: data)
            })
            .disposed(by: bag)
    }

    func showData(with order: OrderDetailData) {
        guard let order = order.detalle.first else { return }
        let shippingItem = order.ordenDetalle.first(where: { $0.sku == SKU_SHIPPING })
        let warrantyItem = order.ordenDetalle.first(where: { $0.sku == SKU_WARRANTY })
        let paymentMethod = order.formasPago.first(where: { $0.principalFP == 1 })
        let royalty = order.ordenDetalle.filter { $0.esRegalia == 1 }

        let products = order.ordenDetalle.filter { product in
            return product.esRegalia != 1 && product.sku != SKU_SHIPPING && product.sku != SKU_WARRANTY
        }
        let productsAmount = products.reduce(0, { $0 + ($1.precioExtendido ?? 0.0) })
        let bono = order.formasPago.filter { $0.idFormaPago == PAYMENT_BONUS }.reduce(0, { $0 + ($1.montoTotal ?? 0.0) })
        var bonus = 0.0
        if bono > 0.0 {
            bonus = bono * -1
        }

        orderLabel.text = "Número de orden: \(order.orden.numOrdenTienda ?? "")"
        if let date = order.orden.fechaOrden {
            createLabel.attributedText = formatHTML(header: "Fecha pedido: ", content: convertDate(date: date) ?? date)
        }
        referenceLabel.attributedText = formatHTML(header: "Número de referencia: ", content: "\(order.orden.idOrden ?? 0)")
        statusLabel.attributedText = formatHTML(header: "Estado: ", content: order.orden.descripcionCupon ?? "")
        originLabel.attributedText = formatHTML(header: "Origen: ", content: order.orden.origen ?? "")

        // Total products
        if let totalProductAmount = order.orden.montoProductos {
            productsLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: totalProductAmount)) ?? "")"
        } else {
            productsLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: productsAmount)) ?? "")"
        }
        // Total delivery
        if let totalDeliveryAmount = order.orden.montoEnvio {
            deliveryLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (totalDeliveryAmount))) ?? "")"
        } else {
            deliveryLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (shippingItem?.precioExtendido ?? 0.0))) ?? "")"
        }
        //deliveryTitleLabel.text = "\(shippingItem?.descripcion ?? "")"
        // Total extraWarranty
        if let totalExtraWarrantyAmount = order.orden.montoExtragarantia {
            warrantyLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (totalExtraWarrantyAmount))) ?? "")"
        } else {
            warrantyLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (warrantyItem?.precioExtendido ?? 0.0))) ?? "")"
        }
        // Total extraWarranty
        if let totalAmount = order.orden.montoBruto {
            totalLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (totalAmount))) ?? "")"
        } else {
            totalLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (order.orden.montoBruto ?? 0.0 - (order.orden.montoDescuento ?? 0.0)))) ?? "")"
        }
        // Total Bonus
        if let totalDiscountAmount = order.orden.montoDescuento {
            discountLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: totalDiscountAmount)) ?? "")"
        } else {
            discountLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: 0.0)) ?? "")"
        }
        // Total Bonus
        if let totalBonusAmount = order.orden.montoBono {
            bonusLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: totalBonusAmount)) ?? "")"
        } else {
            bonusLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: bonus)) ?? "")"
        }
        // Total Final
        if let totalFinalAmount = order.orden.montoNeto {
            totalFinalLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: totalFinalAmount)) ?? "")"
        } else {
            totalFinalLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (order.orden.montoBruto ?? 0.0) - (order.orden.montoDescuento ?? 0.0) + (bonus))) ?? "")"
        }

        guard let deliveryPlace = order.formaEntrega.first else { return }
        if deliveryPlace.tipoEntrega == "20" {
            descriptionDeliveryLabel.text = deliveryPlace.descEntrega
            nameLabel.attributedText = formatHTML(header: "Recoger en tienda: ", content: deliveryPlace.lugarDespacho ?? "")
            addressLabel.isHidden = true
        } else {
            if let place = deliveryPlace.lugarDespacho, !place.removeWhitespace().isEmpty {
                descriptionDeliveryLabel.text = deliveryPlace.descEntrega ?? ""
                nameLabel.text = deliveryPlace.receptorProducto ?? ""
                addressLabel.text = getAddress(with: deliveryPlace)
            } else {
                descriptionDeliveryLabel.isHidden = true
                nameLabel.text = "Recoger en tienda"
                addressLabel.text = deliveryPlace.lugarDespacho ?? ""
            }
        }

        if let cardNumber = paymentMethod?.numeroTarjeta, !cardNumber.isEmpty {
            paymentMethodLabel.text = "\(paymentMethod?.descripcionFP ?? "") - \(cardNumber)"
        } else {
            paymentMethodLabel.text = paymentMethod?.descripcionFP ?? ""
        }
        
        if let totalFinalAmount = order.orden.montoNeto {
            amountLabel.attributedText = formatHTML(header: "Monto: ", content: "₡\(numberFormatter.string(from: NSNumber(value: (totalFinalAmount))) ?? "")")
        } else {
            amountLabel.attributedText = formatHTML(header: "Monto: ", content: "₡\(numberFormatter.string(from: NSNumber(value: (paymentMethod?.montoTotal ?? 0.0))) ?? "")")
        }

        royaltyView.isHidden = royalty.isEmpty
        viewModel.royalties = royalty
        royaltyTableView.reloadData()

        viewModel.products = products
        productsTableView.reloadData()

        if viewModel.royalties.count > 1 {
            royaltyViewHeight.constant = CGFloat(25 + (50 * viewModel.royalties.count))
            royaltyView.layoutIfNeeded()
        }

        if viewModel.products.count > 1 {
            productsViewHeight.constant = CGFloat(25 + (100 * viewModel.products.count))
            productsView.layoutIfNeeded()
        }
        
        if let transactionNumber = order.orden.noTransaccion, !transactionNumber.isEmpty {
            qrView.isHidden = false
            let QRimage = generateQRCode(from: transactionNumber)
            qrImageView.image = QRimage
        } else {
            qrView.isHidden = true
        }
    }

    func getAddress(with data: DeliveryType) -> String {
        var phoneNumber = ""
        var postalCode = ""
        if let phone = data.telefonoReceptor, !phone.isEmpty {
            phoneNumber = "Telefono: \(phone)"
        }
        if let code = data.codigoPostal, !code.isEmpty {
            postalCode = " - Código postal: \(code)"
        }
        return "\(data.direccion ?? ""), \(data.distritoDesc ?? ""), \(data.cantonDesc ?? ""), \(data.provinciaDesc ?? ""), \(phoneNumber)\(postalCode)"
    }

//    func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.ascii)
//        if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
//            QRFilter.setValue(data, forKey: "inputMessage")
//            guard let QRImage = QRFilter.outputImage else {return nil}
//            return UIImage(ciImage: QRImage)
//        }
//        return nil
//    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}

extension OrderDetailTabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.royaltyTableView {
            return viewModel.royalties.count
        } else {
            return viewModel.products.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.royaltyTableView {
            return getRoyaltyCell(tableView, cellForRowAt: indexPath)
        } else {
            return getProductCell(tableView, cellForRowAt: indexPath)
        }
    }

    func getProductCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductOrderDetailTableViewCell", for: indexPath) as? ProductOrderDetailTableViewCell else {
            return UITableViewCell()
        }
        cell.setProductData(with: viewModel.products[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func getRoyaltyCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoyaltyTableViewCell", for: indexPath) as? RoyaltyTableViewCell else {
            return UITableViewCell()
        }

        cell.quantityLabel.text = "\(viewModel.royalties[indexPath.row].cantidad ?? 0)"
        cell.nameLabel.text = viewModel.royalties[indexPath.row].descripcion
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.royaltyTableView {
            return 50
        } else {
            return 100
        }
    }
}
