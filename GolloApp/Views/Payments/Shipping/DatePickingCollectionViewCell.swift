//
//  DatePickingCollectionViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 2/1/24.
//

import UIKit

protocol DatePickingCellDelegate {
    func dateCell(_ productCollectionViewCell: DatePickingCollectionViewCell, willSelectDateWith data: ResponseDate?)
}

class DatePickingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    var delegate: DatePickingCellDelegate?
    var data: ResponseDate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: - Observers
    @objc func contentTapped(_ gesture: UITapGestureRecognizer) {
        guard let data = self.data else { return }
        self.delegate?.dateCell(self, willSelectDateWith: data)
    }
    
    // MARK: - Functions
    private func configureViews() {
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.containerView.addGestureRecognizer(tapGesture)
        self.containerView.layoutIfNeeded()
    }

    func setDateData(with data: ResponseDate?) {
        self.data = data
        
        if data?.selected == true {
            containerView.layer.borderWidth = 2.5
            containerView.layer.borderColor = UIColor.primaryLight.cgColor
            dayLabel.textColor = .darkGray
            dateLabel.textColor = .primary
            monthLabel.textColor = .darkGray
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.white.cgColor
            dayLabel.textColor = .lightGray
            dateLabel.textColor = .darkGray
            monthLabel.textColor = .lightGray
        }
        
        dayLabel.text = data?.day
        dateLabel.text = data?.numberDay
        monthLabel.text = data?.month
    }
}
