//
//  NotificationsData.swift
//  Shoppi
//
//  Created by Rodrigo Osegueda on 26/7/21.
//

import Foundation

public class NotificationsData: Codable {
    let idNotificacion, title, message, from: String?
    let effectiveDate, issueDate, dueDate: Date?
    let image, url, scope, imageList: String?
    let type, status, data: String?
    let deleted: Bool?
    let imageDrawable: Int?
    let idempresa: Int?

    public init(idNotificacion: String?, title: String?, message: String?, from: String?, effectiveDate: Date?, issueDate: Date?, dueDate: Date?, image: String?, url: String?, scope: String?, imageList: String?, type: String?, status: String?, data: String?, deleted: Bool?, imageDrawable: Int?, idempresa: Int?) {
        self.idNotificacion = idNotificacion
        self.title = title
        self.message = message
        self.from = from
        self.effectiveDate = effectiveDate
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.image = image
        self.url = url
        self.scope = scope
        self.imageList = imageList
        self.type = type
        self.status = status
        self.data = data
        self.deleted = deleted
        self.imageDrawable = imageDrawable
        self.idempresa = idempresa
    }
}
