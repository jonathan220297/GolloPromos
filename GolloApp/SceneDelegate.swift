//
//  SceneDelegate.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import FirebaseDynamicLinks

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let host = url.host else {
                return
        }
        
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
            guard error == nil,
                let dynamicLink = dynamicLink,
                let urlString = dynamicLink.url?.absoluteString else {
                    return
            }
            print("Dynamic link host: \(host)")
            print("Dyanmic link url: \(urlString)")
            
            // Handle deep links
            self.handleIncomingDynamicLink(dynamicLink)
            
            print("Dynamic link match type: \(dynamicLink.matchType.rawValue)")
            
            if let dynamicURL = dynamicLink.url?.absoluteString, dynamicURL.contains("/product/") {
                if let range = dynamicURL.range(of: "/product/") {
                    let sku = dynamicURL[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    let userInfo = ["product": sku]
                    NotificationCenter.default.post(name: Notification.Name("showDynamicLinkProduct"), object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        if let userActivity = connectionOptions.userActivities.first {
            if let incomingURL = userActivity.webpageURL {
                _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                    guard error == nil else { return }
                    if let dynamicLink = dynamicLink {
                        self.handleIncomingDynamicLink(dynamicLink)
                        
                        if let dynamicURL = dynamicLink.url?.absoluteString, dynamicURL.contains("/product/") {
                            if let range = dynamicURL.range(of: "/product/") {
                                let sku = dynamicURL[range.upperBound...].trimmingCharacters(in: .whitespaces)
                                let userInfo = ["product": sku]
                                NotificationCenter.default.post(name: Notification.Name("showDynamicLinkProduct"), object: nil, userInfo: userInfo)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("That's weird. My dynamic link object has no url.")
            return
        }
        print("Your incoming link parameter is: \(url.absoluteString)")
    }
    
}

