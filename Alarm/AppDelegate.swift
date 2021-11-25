//
//  AppDelegate.swift
//  Alarm
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        
        //define the custom action
        let snoozeAction = UNNotificationAction(identifier: Alarm.snoozeActionId, title: "Snooze", options: [])
        
        //define the notification
        let alarmCategory = UNNotificationCategory(
            identifier: Alarm.notificationCategoryId,
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction)
        
        center.setNotificationCategories([alarmCategory])
        center.delegate = self
        
        return true
    }
}

