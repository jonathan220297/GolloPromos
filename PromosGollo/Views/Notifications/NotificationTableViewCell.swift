//
//  NotificationTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import Nuke

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var contentCell: UILabel!
    @IBOutlet weak var dateCell: UILabel!

    func setNotification(notification: NotificationsData) {
        if let image = notification.image {
            let url : String = image
            let urlStr : String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            if let convertedURL : URL = URL(string: urlStr) {
                Nuke.loadImage(with: convertedURL, into: imageCell)
            } else {
                imageCell.image = UIImage(named: "empty_image")
            }
        } else {
            imageCell.image = UIImage(named: "empty_image")
        }

        titleCell.text = notification.title
        contentCell.text = notification.message

        if let effective = notification.effectiveDate {
            dateCell.text = effective.toString(dateFormat: "MMM d, yyyy")
        } else {
            let date = Date()
            dateCell.text = date.toString(dateFormat: "MMM d, yyyy")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

