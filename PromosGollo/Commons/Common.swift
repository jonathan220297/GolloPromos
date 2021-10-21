//
//  Common.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

enum ProductsType {
    case categories
    case shops
    case whishlist
    case recents
}

func getMyCustomString(_ key: String) -> String {
    return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func convertToDictionary(text: String) -> [String: Any]? {
    var json = [String : Any]()
    if let data = text.data(using: String.Encoding.utf8) {
        do {
            json = (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any])!
            //Utilidades.debugOnConsole(json)
        } catch let error as NSError {
            print("Something went wrong: \(error.localizedDescription)")
        }
    }
    return json
}

let numberFormatter: NumberFormatter = {
   let nf = NumberFormatter()
    nf.locale = NSLocale.current
    nf.roundingMode = .halfUp
    nf.numberStyle = .decimal
    nf.usesGroupingSeparator = true
    nf.minimumFractionDigits = 2
    nf.maximumFractionDigits = 2
    return nf
}()

// Offers
enum OFFER_TYPE: String {
    case NONE = "G"
    case COMING = "P"
    case NEW = "N"
    case PRICE_CHANGE = "C"
    case INACTIVE = "I"
}

enum GOLLOAPP: String {
    case LOGIN_PROCESS_ID = "01"
    case REGISTER_CLIENT_PROCESS_ID = "03"
    case HOME_PROCESS_ID = "10"
    case ACTIVE_ACCOUNTS_PROCESS_ID = "04"
    case PRESALES_PROCESS_ID = "05"
    case STATUS_PROCESS_ID = "06"
    case ACCOUNT_ITEMS_PROCESS_ID = "07"
    case OFFER_CATEGORIES_PROCESS_ID = "13"
    case CARD_PAYMENT_PROCESS_ID = "11"
    case OFFER_CAT_PROCESS_ID = "14"
    case OFFER_LIST_PROCESS_ID = "15"
    case OFFER_STORES_PROCESS_ID = "16"
    case IS_GOLLO_CUSTOMER_PROCESS_ID = "17"
    case APP_PAYMENT_HISTORY = "20"
    case ACCOUNT_PAYMENT_HISTORY = "21"
}
