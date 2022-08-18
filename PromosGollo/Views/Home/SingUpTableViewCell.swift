//
//  SingUpTableViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 18/8/22.
//

import UIKit
import RxSwift

protocol SignUpCellDelegate: AnyObject {
    func presentEditProfileController()
}

class SingUpTableViewCell: UITableViewCell {
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    
    let bag = DisposeBag()
    weak var delegate: SignUpCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
        configureRx()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Functions
    func configureViews() {
        content.layer.cornerRadius = 10.0
        content.layer.borderWidth = 1.0
        content.layer.borderColor = UIColor.secondaryLabel.cgColor
        informationView.layer.cornerRadius = 10.0
        signupButton.layer.cornerRadius = 10.0
    }
    
    func configureRx() {
        signupButton
            .rx
            .tap
            .subscribe(onNext: {
                self.delegate?.presentEditProfileController()
            })
            .disposed(by: bag)
    }
}
