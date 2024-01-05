//
//  SuggestionsTableViewCell.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/11/23.
//

import UIKit
import RxSwift
import Nuke

protocol SuggestionsCellDelegate: AnyObject {
    func didSelectSuggestionOption(at indexPath: IndexPath)
}

class SuggestionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var suggestionImageView: UIImageView!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    weak var delegate: SuggestionsCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setSuggestionData(with item: LocalSuggestions) {
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        if item.isHeader {
            suggestionImageView.isHidden = true
            suggestionLabel.textColor = .orange
        } else {
            suggestionImageView.isHidden = false
            let imageUrl = item.image?.replacingOccurrences(of: " ", with: "%20")
            if let url = URL(string: imageUrl ?? ""), !item.isBrand {
                Nuke.loadImage(with: url, options: options, into: suggestionImageView)
                suggestionImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
                suggestionImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
            } else {
                suggestionImageView.image = UIImage(named: "ic_registered_brand")
                suggestionImageView.tintColor = .primary
                suggestionImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
                suggestionImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            }
        }
        
        suggestionLabel.text = item.name
    }
    
    func configureRx() {
        detailButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.delegate?.didSelectSuggestionOption(at: self.indexPath)
            })
            .disposed(by: bag)
    }
    
}
