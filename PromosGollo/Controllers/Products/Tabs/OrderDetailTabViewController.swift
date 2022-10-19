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
    @IBOutlet weak var productsLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var deliveryTitleLabel: UILabel!
    @IBOutlet weak var warrantyLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var totalFinalLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var quotaStackView: UIStackView!
    @IBOutlet weak var quotaSwitch: UISwitch!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var productsTableViewHeight: NSLayoutConstraint!

    // MARK: - Constants
    let viewModel: OrderDetailTabViewModel
    let orderId: String
    let bag = DisposeBag()
    let SKU_SHIPPING = "73"
    let SKU_WARRANTY = "4"
    let PAYMENT_BONUS = "90"
    let PAYMENT_METHOD_CARD = "30"

    init(viewModel: OrderDetailTabViewModel, orderId: String) {
        self.viewModel = viewModel
        self.orderId = orderId
        super.init(nibName: "OrderDetailTabViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Detalle de la orden"
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchOrderDetail()
    }

    func configureTableView() {
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
        let paymentMethod = order.formasPago.first

        let products = order.ordenDetalle.filter { product in
            return product.esRegalia != 1 && product.sku != SKU_SHIPPING && product.sku != SKU_WARRANTY
        }
        let productsAmount = products.reduce(0, { $0 + ($1.precioExtendido ?? 0.0) })
        let bono = order.formasPago.filter { $0.idFormaPago == PAYMENT_BONUS }.reduce(0, { $0 + ($1.montoTotal ?? 0.0) })
        var bonus = 0.0
        if bono > 0.0 {
            bonus = bono * -1
        }

        referenceLabel.text = "Número de referencia: \(order.orden.idOrden ?? 0)"
        orderLabel.text = "Número de orden: \(order.orden.numOrdenTienda ?? "")"
        if let date = order.orden.fechaOrden {
            createLabel.text = "Fecha pedido: \(convertDate(date: date) ?? date)"
        }
        productsLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: productsAmount)) ?? "")"
        deliveryLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (shippingItem?.precioExtendido ?? 0.0))) ?? "")"
        deliveryTitleLabel.text = "\(shippingItem?.descripcion ?? "")"
        warrantyLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (warrantyItem?.precioExtendido ?? 0.0))) ?? "")"
        totalLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (order.orden.montoBruto ?? 0.0 - (order.orden.montoDescuento ?? 0.0)))) ?? "")"
        bonusLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: bonus)) ?? "")"
        totalFinalLabel.text = "₡\(numberFormatter.string(from: NSNumber(value: (order.orden.montoBruto ?? 0.0) - (order.orden.montoDescuento ?? 0.0) + (bonus))) ?? "")"

        guard let deliveryPlace = order.formaEntrega.first else { return }
        if let place = deliveryPlace.lugarDespacho, !place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameLabel.text = "Recoger en tienda"
            addressLabel.text = place
        } else {
            nameLabel.text = deliveryPlace.receptorProducto
            addressLabel.text = getAddress(with: deliveryPlace)
        }

        paymentMethodLabel.text = "Tarjeta - \(paymentMethod?.numeroTarjeta ?? "")"
        amountLabel.attributedText = formatHTML(header: "Monto: ", content: "₡\(numberFormatter.string(from: NSNumber(value: (paymentMethod?.montoTotal ?? 0.0))) ?? "")")
        viewModel.products = products
        productsTableView.reloadData()
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

}

extension OrderDetailTabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getProductCell(tableView, cellForRowAt: indexPath)
    }

    func getProductCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductOrderDetailTableViewCell", for: indexPath) as? ProductOrderDetailTableViewCell else {
            return UITableViewCell()
        }
        cell.setProductData(with: viewModel.products[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
