//
//  SceneDelegate.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        print("SceneDelegate is connected!")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
              let _ = url.host else { return }
        
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
            guard error == nil,
                let dynamicLink = dynamicLink,
                let urlString = dynamicLink.url?.absoluteString else {
                    return
            }
            
            // Handle deep links
            self.handleIncomingDynamicLink(dynamicLink)
            
            if urlString.contains("/product/") {
                if let range = urlString.range(of: "/product/") {
                    let sku = urlString[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    let userInfo = ["product": sku]
                    NotificationCenter.default.post(name: Notification.Name("showDynamicLinkProduct"), object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        _ = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink, error) in
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
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("That's weird. My dynamic link object has no url.")
            return
        }
        print("Your incoming link parameter is: \(url.absoluteString)")
    }
    
}

