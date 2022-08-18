//
//  AccountsTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

protocol AccountsDelegate {
    func OpenItems(with index: Int)
}

class AccountsTableViewCell: UITableViewCell {

    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var openDetailImageView: UIImageView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var itemsButton: UIButton!
    @IBOutlet weak var initialAmountLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet weak var amountArrearsLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var dayArrearsLabel: UILabel!

    var delegate: AccountsDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setAccount(model: AccountsDetail, index: Int) {
        accountTypeLabel.text = model.tipoCuenta
        accountLabel.text = "Número de cuenta: \(model.numCuenta ?? "")"
        startDateLabel.text = "Fecha de inicio: \(model.fecha ?? "")"
        if let initial = numberFormatter.string(from: NSNumber(value: model.montoInicial ?? 0.0)) {
            initialAmountLabel.text = "₡" + String(initial)
        }
        if let current = numberFormatter.string(from: NSNumber(value: model.saldoActual ?? 0.0)) {
            currentAmountLabel.text = "₡" + String(current)
        }
        if let total = numberFormatter.string(from: NSNumber(value: model.montoCancelarCuenta ?? 0.0)) {
            totalPaymentLabel.text = "₡" + String(total)
        }

        paymentDateLabel.text = model.fechaPago
        if let fee = numberFormatter.string(from: NSNumber(value: model.montoCuota ?? 0.0)) {
            feeAmountLabel.text = "₡" + String(fee)
        }
        if let arrears = numberFormatter.string(from: NSNumber(value: model.montoAtraso ?? 0.0)) {
            amountArrearsLabel.text = "₡" + String(arrears)
        }
        if let days = model.diasAtraso {
            dayArrearsLabel.text = String(days)
        }

        itemsButton.addTarget(self, action: #selector(itemsButtonTapped(_:)), for: .touchUpInside)
        itemsButton.tag = index

        self.progressShape(progress: 10.0)
    }

    @IBAction func itemsButtonTapped(_ sender: UIButton) {
        delegate.OpenItems(with: sender.tag)
    }

    func progressShape(progress: Double) {
        // Configuration views
        let trackLayer = CAShapeLayer()
        let shapeLayer = CAShapeLayer()

        let center = chartView.center

        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi, endAngle: CGFloat.pi, clockwise: true)

        // Track layer
        trackLayer.path = circularPath.cgPath

        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor

        chartView.layer.addSublayer(trackLayer)

        // Progress layer
        shapeLayer.path = circularPath.cgPath

        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor

        chartView.layer.addSublayer(shapeLayer)
    }

}

