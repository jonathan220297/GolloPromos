//
//  StatusTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 26/8/21.
//

import AAInfographics
import UIKit

protocol StatusDelegate {
    func OpenItems(with index: Int)
}

class StatusTableViewCell: UITableViewCell {

    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var itemsButton: UIButton!
    @IBOutlet weak var initialAmountLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet weak var amountArrearsLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var dayArrearsLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var chartInfo: UILabel!
    
    var delegate: StatusDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setStatus(model: AccountData, index: Int) {
        accountLabel.text = "Número de cuenta: \(model.numCuenta ?? "")"
        if let date = model.fecha {
            startDateLabel.text = "Fecha inicio: \(date.formatStringDateGollo())"
        }
        if let initial = numberFormatter.string(from: NSNumber(value: model.montoInicial ?? 0.0)) {
            initialAmountLabel.text = "₡" + String(initial)
        }
        if let current = numberFormatter.string(from: NSNumber(value: model.saldoActual ?? 0.0)) {
            currentAmountLabel.text = "₡" + String(current)
        }
        if let total = numberFormatter.string(from: NSNumber(value: model.montoCancelarCuenta ?? 0.0)) {
            totalPaymentLabel.text = "₡" + String(total)
        }

        if let paymentDate = model.fechaPago {
            paymentDateLabel.text = paymentDate.formatStringDateGollo()
        }
        if let fee = numberFormatter.string(from: NSNumber(value: model.montoPago ?? 0.0)) {
            feeAmountLabel.text = "₡" + String(fee)
        }
        if let arrears = numberFormatter.string(from: NSNumber(value: model.montoSugeridoPago ?? 0.0)) {
            amountArrearsLabel.text = "₡" + String(arrears)
        }
        dayArrearsLabel.text = "\(model.diasAtraso ?? 0)"

        itemsButton.addTarget(self, action: #selector(itemsButtonTapped(_:)), for: .touchUpInside)
        itemsButton.tag = index
        
        let aaChartView = AAChartView()
        aaChartView.frame = CGRect(x: 0,
                                    y: -20,
                                    width: 200,
                                    height: 120)
        self.chartView.addSubview(aaChartView)
        let firstValue = round((model.montoInicial ?? 0.0) - (model.saldoActual ?? 0.0))
        if let amountPaid = numberFormatter.string(from: NSNumber(value: firstValue)) {
            let percentPaid = round((firstValue * 100) / (model.montoInicial ?? 0.0))
            chartInfo.text = "₡" + amountPaid + " (\(percentPaid)%)"
        }
        let chartConfiguration = doubleLayerHalfPieChart(firstValue, model.saldoActual ?? 0.0)
        aaChartView.aa_drawChartWithChartOptions(chartConfiguration)
    }

    @IBAction func itemsButtonTapped(_ sender: UIButton) {
        delegate.OpenItems(with: sender.tag)
    }
    
    private func doubleLayerHalfPieChart(_ firstValue: Double, _ secondValue: Double) -> AAOptions {
        let aaChartModel = AAChartModel()
            .chartType(.pie)
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .colorsTheme(["#14c43d","#88ba94"])
            .series([
                AASeriesElement()
                    .name("")
                    .size("100%")
                    .innerSize("70%")
                    .borderWidth(0)
                    .allowPointSelect(false)
                    .data([
                        ["", firstValue],
                        ["", secondValue],
                    ])
            ])

        let aaOptions = aaChartModel.aa_toAAOptions()

        aaOptions.plotOptions?.pie?
            .startAngle(-130)
            .endAngle(130)

        return aaOptions
    }
}
