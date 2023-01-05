//
//  NotificationDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import Nuke

class NotificationDetailViewController: UIViewController {

    // Extras
    var notification: NotificationsData?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nImageView: UIImageView!
    @IBOutlet weak var nImageContraint: NSLayoutConstraint!
    @IBOutlet weak var effectiveDateLabel: UILabel!
    @IBOutlet weak var issueDate: UILabel!

    @IBOutlet weak var divView: UIView!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notificación"
        showData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Functions
    func showData() {
        if let n = notification {
            titleLabel.text = n.title
            messageLabel.text = n.message

            if let image = n.image?.replacingOccurrences(of: " ", with: "%20") {
                if let url = URL(string: image) {
                    Nuke.loadImage(with: url, into: nImageView)
                    nImageView.isHidden = false
                } else {
                    nImageView.isHidden = true
                }
            } else {
                nImageView.isHidden = true
                let newMultiplier: CGFloat = 0.0001
                DispatchQueue.main.async {
                    self.nImageContraint = self.nImageContraint.setMultiplier(multiplier: newMultiplier)
                    self.nImageView.alpha = 0
                }
            }
        }
    }

    func openWebPage(url: String) {
        let url: String = url
        let urlStr: String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let convertedURL: URL = URL(string: urlStr), UIApplication.shared.canOpenURL(convertedURL) {
            UIApplication.shared.open(convertedURL, options: [:])
        }
    }

    // Rezise Image
    internal var aspectConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                nImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                nImageView.addConstraint(aspectConstraint!)
            }
        }
    }

    func setCustomImage(image : UIImage) {
        let aspect = image.size.width / image.size.height

        let constraint = NSLayoutConstraint(item: nImageView!,
                                            attribute: NSLayoutConstraint.Attribute.width,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: nImageView,
                                            attribute: NSLayoutConstraint.Attribute.height,
                                            multiplier: aspect,
                                            constant: 0.0)
        constraint.priority = UILayoutPriority(rawValue: 999)

        aspectConstraint = constraint

        nImageView.image = image
    }

}

