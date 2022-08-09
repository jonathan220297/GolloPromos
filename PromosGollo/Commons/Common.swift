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

func convertDate(date: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let date = dateFormatter.date(from: date)
    return date?.toString(dateFormat: "MMM dd,yyyy")
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

func formatHTML(header: String, content: String) -> NSMutableAttributedString {
    let someValue : String = content
    let text = NSMutableAttributedString(string: header)
    text.append(NSAttributedString(string: someValue, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)]))
    return text
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

enum Payment: Int {
    case PAYMENT_SUGGESTED = 1
    case PAYMENT_INSTALLMENT = 2
    case PAYMENT_TOTAL_PENDING = 3
}

func getToken() -> String {
    guard let data = KeychainManager.load(key: "token") else {
        return ""
    }
    let token = String(data: data, encoding: .utf8)
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjSXBBRExwaDJvZVRWeUkxYVBtRE5hWU84RGsyIiwiZW1wcmVzYSI6IjEwIiwidG9rZW4iOiIiLCJmdWxsTmFtZSI6IiIsInJvbGUiOiJVc2VyIiwianRpIjoiNjA1Y2U1OGEtOWJiOC00YmI0LTgwMDMtZWE1NmEzZDZlOTExIiwibmJmIjoxNjU5OTc2MDA0LCJleHAiOjE2NjAwNjI0MDQsImlzcyI6Imh0dHA6Ly83NC4yMDguMTUwLjQ0L1Byb21vc0FQSSIsImF1ZCI6Imh0dHA6Ly83NC4yMDguMTUwLjQ0L1Byb21vc0FQSSJ9.g6e2IT9eKQTerdkHNKq-i8zS823C_omNmhKrMavGN4o"
}

func getDefaultBaseHeaderRequest(with processId: String,
                                 integrationId: String? = nil) -> Encabezado {
    let encabezado = Encabezado(idProceso: processId,
                                idDevice: "",
                                idUsuario: UserManager.shared.userData?.uid ?? "",
                                timeStamp: String(Date().timeIntervalSince1970),
                                idCia: 10,
                                token: getToken() ,
                                integrationId: integrationId)
    return encabezado
}
