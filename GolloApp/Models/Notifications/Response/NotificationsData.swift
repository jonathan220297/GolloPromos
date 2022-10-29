//
//  NotificationsData.swift
//  Shoppi
//
//  Created by Rodrigo Osegueda on 26/7/21.
//

import Foundation

public class NotificationsData: Codable {
    let IdNotification, idType, issueDate, title, message: String?
    let image, imageList, url: String?
    let type, read: String?

    public init(IdNotification: String?, idType: String?, issueDate: String?, title: String?, message: String?, image: String?, imageList: String?, url: String?, type: String?, read: String?) {
        self.IdNotification = IdNotification
        self.idType = idType
        self.issueDate = issueDate
        self.title = title
        self.message = message
        self.image = image
        self.imageList = imageList
        self.url = url
        self.type = type
        self.read = read
    }
}
