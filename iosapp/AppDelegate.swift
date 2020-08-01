//
//  AppDelegate.swift
//  iosapp
//

import UIKit
import BMSCore
import IBMCloudAppID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let contents = Bundle.main.path(forResource:"BMSCredentials", ofType: "plist"), let _ = NSDictionary(contentsOfFile: contents) {
                  let region = AppID.REGION_GERMANY
                  let bmsclient = BMSClient.sharedInstance
                  let backendGUID = "b9d727ea-c81e-42f9-ba3c-72b4ec781042"
                  bmsclient.initialize(bluemixRegion: region)
                  let appid = AppID.sharedInstance
                  appid.initialize(tenantId: backendGUID, region: region)
                  let appIdAuthorizationManager = AppIDAuthorizationManager(appid:appid)
                  bmsclient.authorizationManager = appIdAuthorizationManager
                  TokenStorageManager.sharedInstance.initialize(tenantId: backendGUID)
              }

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options :[UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return AppID.sharedInstance.application(application, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
