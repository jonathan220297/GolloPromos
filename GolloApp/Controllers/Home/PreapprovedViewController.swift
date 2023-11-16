//
//  PreapprovedViewController.swift
//  GolloApp
//
//  Created by Jonathan Rodriguez on 16/11/23.
//

import Nuke
import RxSwift
import UIKit

class PreapprovedViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var descriptionTitle: NSAttributedString?
    var image: String?
    let bag = DisposeBag()
    
    init(description: NSAttributedString?, image: String?) {
        super.init(nibName: "PreapprovedViewController", bundle: nil)
        self.descriptionTitle = description
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setData(with: descriptionTitle, image: image)
        configureRx()
    }
    
    // MARK: - Function
    func configureViews() {
        popUpView.layer.cornerRadius = 15
    }
    
    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
    
    func setData(with description: NSAttributedString?, image: String?) {
        guard let description = description else { return }
        descriptionText.attributedText = description
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        if let url = URL(string: image?.replacingOccurrences(of: " ", with: "%20") ?? "") {
            Nuke.loadImage(with: url, options: options, into: mainImageView)
        } else {
            self.mainImageView.image = UIImage(named: "empty_image")
        }
    }
}
