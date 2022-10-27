//
//  SearchHistoryCollectionViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 26/10/22.
//

import UIKit

protocol SearchHistoryDelegate: AnyObject {
    func deleteItem(at indexPath: IndexPath)
}

class SearchHistoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var deleteHistory: UIButton!

    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    weak var delegate: SearchHistoryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func deleteItem(_ sender: Any) {
        delegate?.deleteItem(at: self.indexPath)
    }

}
