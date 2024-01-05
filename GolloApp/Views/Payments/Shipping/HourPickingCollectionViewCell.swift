//
//  HourPickingCollectionViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 3/1/24.
//

import UIKit

protocol HourPickingCellDelegate {
    func hourCell(_ productCollectionViewCell: HourPickingCollectionViewCell, willSelectHourWith data: ResponseHours?)
}

class HourPickingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var fromHourLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var toHourLabel: UILabel!
    
    var delegate: HourPickingCellDelegate?
    var data: ResponseHours?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Observers
    @objc func contentTapped(_ gesture: UITapGestureRecognizer) {
        guard let data = self.data else { return }
        self.delegate?.hourCell(self, willSelectHourWith: data)
    }
    
    // MARK: - Functions
    private func configureViews() {
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.containerView.addGestureRecognizer(tapGesture)
        self.containerView.layoutIfNeeded()
    }
    
    func setHourData(with data: ResponseHours?) {
        self.data = data
        
        if data?.selected == true {
            containerView.layer.borderWidth = 2.5
            containerView.layer.borderColor = UIColor.primaryLight.cgColor
            fromDateLabel.textColor = .primary
            fromHourLabel.textColor = .primary
            toDateLabel.textColor = .primary
            toHourLabel.textColor = .primary
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.white.cgColor
            fromDateLabel.textColor = .darkGray
            fromHourLabel.textColor = .darkGray
            toDateLabel.textColor = .darkGray
            toHourLabel.textColor = .darkGray
        }
        
        fromDateLabel.text = data?.fromDate
        fromHourLabel.text = data?.fromHour?.lowercased()
        toDateLabel.text = data?.toDate
        toHourLabel.text = data?.toHour?.lowercased()
    }

}
