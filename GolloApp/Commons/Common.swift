//
//  Common.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import FirebaseAuth

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
    return date?.toString(dateFormat: "dd/MM/yyyy")
}

func sizeOfImageAt(url: URL) -> CGSize? {
    // with CGImageSource we avoid loading the whole image into memory
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

    let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
        return nil
    }

    if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
       let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
        return CGSize(width: width, height: height)
    } else {
        return nil
    }
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

func formatHTML(header: String, content: String, size: CGFloat? = nil) -> NSMutableAttributedString {
    let someValue : String = content
    let text = NSMutableAttributedString(string: header)
    text.append(NSAttributedString(string: someValue, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: size != nil ? size! : UIFont.systemFontSize)]))
    return text
}

let numberFormatter: NumberFormatter = {
   let nf = NumberFormatter()
    nf.locale = NSLocale.current
    nf.roundingMode = .halfUp
    nf.numberStyle = .decimal
    nf.usesGroupingSeparator = true
    nf.minimumFractionDigits = 0
    nf.maximumFractionDigits = 0
    nf.decimalSeparator = ","
    nf.groupingSeparator = "."
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
    case CURRENCY_SIMBOL = "₡"
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
    case ADD_TO_CART_PROCESS_ID = "22"
    case STATES_CITIES = "24"
    case PRODUCT_PAYMENT = "26"
    case FREIGHTS_PROCESS_ID = "28"
    case OFFER_DETAIL_PROCESS_ID = "29"
    case ORDERS_PROCESS_ID = "30"
    case ORDER_DETAIL_PROCESS_ID = "31"
    case SAVE_ADDRESS = "32"
    case ADDRESS_LIST = "34"
    case DELETE_ADDRESS = "35"
    case THIRD_PARTY_CUSTOMER = "41"
    case SEARCH_PRODUCTS_PROCESS_ID = "42"
    case CATEGORIES_FILTER_PROCESS_ID = "43"
    case FILTERED_PRODUCTS_PROCESS_ID = "44"
    case PAYMENT_METHODS_PROCESS_ID = "45"
    case DEVICE_TOKEN_PROCESS_ID = "46"
    case READ_NOTIFICATION_PROCESS_ID = "47"
    case NOTIFICATIONS_PROCESS_ID = "48"
    case PROVENANCE_PROCESS_ID = "50"
    case UNREAD_NOTIFICATIONS_PROCESS_ID = "51"
    case VERIFICATION_SERVICE_PROCESS_ID = "52"
    case REGISTER_DEVICE_PROCESS_ID = "53"
    case REMOVE_USER_PROCESS_ID = "54"
    case EMMA_TERMS_PROCESS_ID = "57"
    case PROFILE_CHANGE_USER_PIN_PROCESS_ID = "58"
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
    return token ?? ""
}

func getDefaultBaseHeaderRequest(with processId: String,
                                 integrationId: String? = nil) -> Encabezado {
    let idClient: String? = UserManager.shared.userData?.uid != nil ? UserManager.shared.userData?.uid : Auth.auth().currentUser?.uid
    let idDevice: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    let encabezado = Encabezado(idProceso: processId,
                                idDevice: idDevice,
                                idUsuario: idClient ?? idDevice,
                                timeStamp: String(Date().timeIntervalSince1970),
                                idCia: 10,
                                token: getToken() ,
                                integrationId: integrationId)
    return encabezado
}

func getDeviceID() -> String {
//    let uniqueID = UIDevice.current.identifierForVendor?.uuidString ?? ""
//    return uniqueID
    guard let deviceID = UserDefaults.standard.object(forKey: "deviceID") as? String else {
        return ""
    }
    return deviceID
}

struct Variables {
    static var isRegisterUser = false
    
    // Company
    var GOLLO_COMPANY = "10"
    var GOLLO_STORE = "144"
    var VERSION_CODE = "1.0.4"
    static var isClientUser = false
    static var isLoginUser = false
    static var userProfile: UserInfo? = nil
    static var notificationsToken = ""
    static var openPushNotificationFlow = false
    static var notificationFlowPayload: [String: Any]? = nil
}

enum APP_NOTIFICATIONS: String {
    case GENERAL = "1"
    case ORDER = "3"
}

enum NOTIFICATION_NAME {
    static let NOTIFICATION_FLOW = "notificationFlow"
}

enum CarManagerType: String {
    case SCAN_AND_GO = "ScanAndGo"
    case PRODUCT_LIST = "ProductList"
}
