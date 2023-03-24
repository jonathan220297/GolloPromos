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
        
        switch UIApplication.shared.applicationState {
        case .background, .inactive:
            // background
            Variables.openPushNotificationFlow = true
            Variables.notificationFlowPayload = userInfo
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_NAME.NOTIFICATION_FLOW), object: nil)
        case .active:
            // foreground
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                configurePage(with: topController.navigationController, userInfo)
            } else {
                configurePage(with: nil, userInfo)
            }
        default:
            break
        }
    }
    
    func configurePage(with navController: UINavigationController?, _ userInfo: [String: Any]) {
        if let navController = navController {
            if let notificationType = userInfo["type"] as? String {
                switch(notificationType) {
                case APP_NOTIFICATIONS.GENERAL.rawValue:
                    let vc = NotificationsViewController.instantiate(fromAppStoryboard: .Notifications)
                    vc.modalPresentationStyle = .fullScreen
                    vc.fromNotifications = true
                    navController.pushViewController(vc, animated: true)
                case APP_NOTIFICATIONS.ORDER.rawValue:
                    let orderDetailTabViewController = OrderDetailTabViewController(
                        viewModel: OrderDetailTabViewModel(),
                        orderId: userInfo["idType"] as? String ?? "",
                        fromNotifications: true
                    )
                    orderDetailTabViewController.modalPresentationStyle = .fullScreen
                    navController.pushViewController(orderDetailTabViewController, animated: true)
                default:
                    print("None action.")
                }
            }
        } else {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
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
                        let navController = UINavigationController(rootViewController: vc)
                        navController.modalPresentationStyle = .fullScreen
                        topController.present(navController, animated: true)
                    case APP_NOTIFICATIONS.ORDER.rawValue:
                        let orderDetailTabViewController = OrderDetailTabViewController(
                            viewModel: OrderDetailTabViewModel(),
                            orderId: userInfo["idType"] as? String ?? "",
                            fromNotifications: true
                        )
                        let navController = UINavigationController(rootViewController: orderDetailTabViewController)
                        navController.modalPresentationStyle = .fullScreen
                        topController.present(navController, animated: true)
                    default:
                        print("None action.")
                    }
                }
            }
        }
    }
}
