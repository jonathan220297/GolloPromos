//
//  Data+Extension.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 11/3/23.
//

import Foundation

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
