//
//  NotificationTypeTransitionManager.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 13/3/23.
//

import Foundation
import UIKit

class NotificationTypeTransitionManager {
    func nonActiveNotificationTypeTransition(with userInfo: [String: Any], isInactiveApp: Bool) {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if isInactiveApp {
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let notificationType = userInfo["type"] as? String {
                    switch(notificationType) {
                    case APP_NOTIFICATIONS.GENERAL.rawValue:
                        let vc = NotificationsViewController.instantiate(fromAppStoryboard: .Notifications)
                        vc.modalPresentationStyle = .fullScreen
                        vc.fromNotifications = true
                        topController.present(vc, animated: true)
                    case APP_NOTIFICATIONS.ORDER.rawValue:
                        let orderDetailTabViewController = OrderDetailTabViewController(
                            viewModel: OrderDetailTabViewModel(),
                            orderId: userInfo["idType"] as? String ?? "",
                            fromNotifications: true
                        )
                        orderDetailTabViewController.modalPresentationStyle = .fullScreen
                        topController.present(orderDetailTabViewController, animated: true)
                    default:
                        print("None action.")
                    }
                }
            }
        } else {
            Variables.openPushNotificationFlow = true
            Variables.notificationFlowPayload = userInfo
        }
    }
}
