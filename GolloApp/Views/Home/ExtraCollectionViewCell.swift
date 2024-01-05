//
//  ExtraCollectionViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 12/9/23.
//

import UIKit


class ExtraCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var content: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        content.layer.cornerRadius = 10.0
        
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOpacity = 0.3
        self.contentView.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
        self.contentView.layer.shadowRadius = 3.0
    }
}
