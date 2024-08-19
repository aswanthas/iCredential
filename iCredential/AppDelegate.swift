//
//  AppDelegate.swift
//  iCredential
//
//  Created by Aswanth K on 19/08/24.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var shared: AppDelegate!
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Handle transition to inactive state
        removeAuthenticationObserver()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle transition to background state
        removeAuthenticationObserver()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Handle transition back to the foreground
        addAuthenticationObserver()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Handle when the app becomes active
        triggerAuthentication()
    }

    func triggerAuthentication() {
        NotificationCenter.default.post(name: NSNotification.Name("TriggerAuthentication"), object: nil)
    }
    
    func addAuthenticationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAuthenticationNotification), name: NSNotification.Name("TriggerAuthentication"), object: nil)
    }
    
    func removeAuthenticationObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TriggerAuthentication"), object: nil)
    }
    
    @objc private func handleAuthenticationNotification() {
        debugPrint("Handling authentication notification...")
        // Handle Face ID authentication here
        // Once authenticated, remove observer if needed
        removeAuthenticationObserver()
    }
}
