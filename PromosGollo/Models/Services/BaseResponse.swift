//
//  BaseResponse.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation

class BaseResponse<T: Decodable>: Decodable {
    var status: Bool?
    var message: String?
    var debugMessage: String?
    var mapID: String?
    var data: T?
}
