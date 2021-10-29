//
//  EmptyTableView.swift
//  PromosGollo
//
//  Created by Jonathan  Rodriguez on 28/10/21.
//

import UIKit

class EmptyTableView: UIView {
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyDescriptionLabel: UILabel!
    
    class func instanceFromNib() -> EmptyTableView {
        return UINib(nibName: "EmptyTableView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! EmptyTableView
    }
    
    func setEmptyData(with image: String,
                      _ title: String,
                      _ description: String) {
        emptyImageView.image = UIImage(named: image)
        emptyTitleLabel.text = title
        emptyDescriptionLabel.text = description
    }
    
}
