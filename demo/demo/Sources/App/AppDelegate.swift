//
//  AppDelegate.swift
//  demo
//
//  Created by СloudPayments on 26/03/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
//

import UIKit
import Cloudpayments

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
                // Инициализируйте SDK
                // Если в проекте используется YandexPay, то необходимо указать соответсвующие параметры:
                // yandexPayAppId - ваш appId для YandexPay
                // sandboxMode - режим песочницы YandexPay
                let yaAppId = "3cf72c47-3027-44f5-b80f-054b0763a298"
                try CloudPaymentsSDK.initialize(yandexPayAppId: yaAppId, yandexPaySandboxMode: true)
            } catch {
                fatalError("Unable to initialize CloudPaymentsSDK.")
            }
               
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        _ = CloudPaymentsSDK.instance.applicationDidReceiveUserActivity(userActivity)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        _ = CloudPaymentsSDK.instance.applicationDidReceiveOpen(url, sourceApplication: options[.sourceApplication] as? String)
        return true
    }
        
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        CloudPaymentsSDK.instance.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        CloudPaymentsSDK.instance.applicationDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

