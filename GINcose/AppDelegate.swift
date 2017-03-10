//
//  AppDelegate.swift
//  GINcose
//
//  Created by Joe Ginley on 12/19/15.
//  Copyright © 2015 GINtech Systems. All rights reserved.
//

import UIKit
import RealmSwift

let appDel = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var glucoseTimer :Timer!
    
    let defaultTransmitter = Transmitter(ID: "")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    //Do nothing.
                }
        })
        
        let homeVC = HomeViewController(nibName:"HomeViewController", bundle:nil)
        self.window!.rootViewController = homeVC
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if (glucoseTimer == nil) {
            //Every 5 minutes (+5 seconds to offset Dexcom) &  check if there is a new glucose object, if so see what we can do with it.
            glucoseTimer = Timer.scheduledTimer(timeInterval: 305.0, target: self, selector: #selector(sendLocalNotification), userInfo: nil, repeats: true)
            
            NSLog("GlucoseTimer Started")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        if (glucoseTimer != nil) {
            glucoseTimer.invalidate()
            glucoseTimer = nil
            
            NSLog("GlucoseTimer Stopped")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        application.applicationIconBadgeNumber = 0
    }
    
    func sendLocalNotification() {
        let realm = try! Realm()
        let lastTwoGlucoses = realm.objects(GlucoseInfo.self).sorted(byProperty: "timestamp", ascending: false)
        
        let previousGlucose :GlucoseInfo? = lastTwoGlucoses[1]
        let newestGlucose :GlucoseInfo? = lastTwoGlucoses[0]
        
        let localNotification = UILocalNotification()
        localNotification.timeZone = TimeZone.current
        localNotification.fireDate = Date()
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        
        if (newestGlucose != nil && previousGlucose != nil) {
            if (newestGlucose!.glucose < 210 && previousGlucose!.glucose >= 210) {
                if #available(iOS 8.2, *) {
                    localNotification.alertTitle = "Stable Sugar Alert"
                }
                localNotification.alertBody = String(format: "Your blood sugar is stable, now at %d", newestGlucose!.glucose)
            }
        }
        else if (newestGlucose != nil && previousGlucose == nil) {
            if (newestGlucose!.glucose >= 210) {
                if #available(iOS 8.2, *) {
                    localNotification.alertTitle = "High Sugar Alert"
                }
                localNotification.alertBody = String(format: "Your blood sugar is high at %d", newestGlucose!.glucose)
            }
            else if (newestGlucose!.glucose <= 90) {
                if #available(iOS 8.2, *) {
                    localNotification.alertTitle = "Low Sugar Alert"
                }
                localNotification.alertBody = String(format: "Your blood sugar is low at %d", newestGlucose!.glucose)
            }
        }
        else {
            //Will it ever reach here?
        }
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    let glucoseDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return dateFormatter
    }()
}

