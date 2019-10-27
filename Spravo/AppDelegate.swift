//
//  AppDelegate.swift
//  Spravo
//
//  Created by Onix on 9/24/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    var reachability: Reachability?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        appCoordinator = AppCoordinator(window: window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForReachability), name: NSNotification.Name.reachabilityChanged, object: nil)
        self.reachability = Reachability.forInternetConnection()
        self.reachability?.startNotifier()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    @objc func checkForReachability(notification: Notification) {
        guard let reachability = notification.object as? Reachability,
            let rootVC = self.window?.rootViewController else { return }
        if !reachability.isReachable() {
            updateUIonMainThread {
                guard let errorController = Storyboard.service.controller(withClass: ErrorScreenVC.self) else { return }
                errorController.image = UIImage(named: "Disconnected")
                errorController.text = NSLocalizedString("ImportPhoneContacts.ErrorInternetConnection", comment: "Request to check internet connection")
                rootVC.modalPresentationStyle = .overCurrentContext
                rootVC.present(errorController, animated: true, completion: nil)
            }
        } else {
            if rootVC is UINavigationController {
                let topController = (rootVC as! UINavigationController).visibleViewController
                if topController is ErrorScreenVC {
                    topController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
