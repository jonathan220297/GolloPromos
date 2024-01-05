//
//  PreapprovedCollectionViewCell.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 16/11/23.
//

import UIKit

class PreapprovedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var descriptionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Functions
    func configureData(with description: NSAttributedString?) {
        guard let description = description else { return }
        descriptionText.attributedText = description
    }
}
