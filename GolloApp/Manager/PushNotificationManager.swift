//
//  PushNotificationManager.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 7/11/22.
//

import UIKit
import FirebaseMessaging

class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
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
        let userInfo = response.notification.request.content.userInfo
        print("Messaging PushNotificationManager: \(userInfo)")
        completionHandler()
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userInfo = notification.request.content.userInfo as? [String: Any] {
            print("UserInfo PushNotificationManager: \(userInfo)")
        }
        print("UserInfo PushNotificationManager nil")
        completionHandler([.alert, .sound, .badge])
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  willPresent notification: UNNotification) async
//        -> UNNotificationPresentationOptions {
//        let userInfo = notification.request.content.userInfo
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // ...
//
//        // Print full message.
//        print("Message PushNotificationManager (fullMessage): \(userInfo)")
//
//        // Change this to your preferred presentation option
//        return [[.alert, .sound]]
//      }

//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  didReceive response: UNNotificationResponse) async {
//        let userInfo = response.notification.request.content.userInfo
//
//        // ...
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // Print full message.
//        print(userInfo)
//      }
    
}
