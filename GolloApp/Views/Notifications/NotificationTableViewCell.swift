//
//  NotificationTableViewCell.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import Nuke

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var contentCell: UILabel!
    @IBOutlet weak var dateCell: UILabel!

    func setNotification(notification: NotificationsData) {
        if notification.type == "3" {
            imageViewCell.image = UIImage(named: "ic_bag")
        } else {
            imageViewCell.image = UIImage(named: "ic_notification")
        }


        titleCell.text = notification.title
        contentCell.text = notification.message

        if notification.read == "N" {
            titleCell.textColor = UIColor.black
            contentCell.textColor = UIColor.black
        }

        if let date = notification.issueDate {
            dateCell.text = "Fecha: \(date)"
        } else {
            let date = Date()
            dateCell.text = "Fecha: \(date.toString(dateFormat: "MMM d, yyyy"))"
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

