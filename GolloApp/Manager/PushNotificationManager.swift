//
//  PushNotificationManager.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 7/11/22.
//

import UIKit
import FirebaseMessaging

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var notificationTypeManager = NotificationTypeTransitionManager()
    
    func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        updateFirestorePushTokenIfNeeded()
    }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            print("Token PushNotificationManager: \(token)")
            Variables.notificationsToken = token
        }
    }

    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        print("UserInfo PushNotificationManager internal didReceive: \(userInfo) ~~ \(userInfo["type"] as? Int ?? 0) ~~ \(userInfo["idType"] as? Int ?? 0)")
        notificationTypeManager.nonActiveNotificationTypeTransition(with: userInfo)
        completionHandler()
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userInfo = notification.request.content.userInfo as? [String: Any] {
            print("UserInfo PushNotificationManager willPresent: \(userInfo) ~~ \(userInfo["type"] as? Int ?? 0) ~~ \(userInfo["idType"] as? Int ?? 0)")
        }
        completionHandler([.alert, .sound, .badge])
    }
    
}
