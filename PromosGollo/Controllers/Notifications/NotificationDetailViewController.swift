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

        showData()
    }

    // MARK: - Functions
    func showData() {
        if let n = notification {
            titleLabel.text = n.title
            messageLabel.text = n.message

            if let image = n.image {
                if let url = URL(string: APDLGT.GIMGURL + (image)) {
                    Nuke.loadImage(with: url, into: nImageView)
                }
            } else {
                let newMultiplier: CGFloat = 0.0001
                DispatchQueue.main.async {
                    self.nImageContraint = self.nImageContraint.setMultiplier(multiplier: newMultiplier)
                    self.nImageView.alpha = 0
                }
            }

            if let due = n.dueDate {
                effectiveDateLabel.text = "Válido hasta el \(due.toString(dateFormat: "MMM d, yyyy"))"
            } else {
                let date = Date()
                effectiveDateLabel.text = "Válido hasta el \(date.toString(dateFormat: "MMM d, yyyy"))"
            }

            if let effective = n.effectiveDate {
                issueDate.text = "Fecha de publicación: \(effective.toString(dateFormat: "MMM d, yyyy"))"
            } else {
                let date = Date()
                issueDate.text = "Fecha de publicación: \(date.toString(dateFormat: "MMM d, yyyy"))"
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

