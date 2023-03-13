//
//  AppDelegate.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import CoreData
import XCGLogger
import AppTrackingTransparency
import AdSupport
import FacebookCore
import UserNotifications

let log = XCGLogger.default

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.requestTracking()
        }
        
        FirebaseApp.configure()
        
        PushNotificationManager().registerForPushNotifications(application: application)

        Messaging.messaging().delegate = self
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func requestTracking() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { (status) in
                switch status{
                case .authorized:
                    Settings.isAutoLogAppEventsEnabled = true
                    Settings.isAdvertiserIDCollectionEnabled = true
                    break
                case .denied:
                    Settings.isAutoLogAppEventsEnabled = false
                    Settings.isAdvertiserIDCollectionEnabled = false
                    break
                default:
                    break
                }
            })
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "GolloApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // 1. Check to see if permission is granted
            print("Granted \(granted)")
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                print("Granted \(granted)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Available token in simulator: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("i am not available in simulator :( \(error)")
    }
}

