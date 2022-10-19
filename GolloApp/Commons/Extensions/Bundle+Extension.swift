//
//  Bundle+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
