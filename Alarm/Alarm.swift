//
//  Alarm.swift
//  Alarm
//
//  Created by Eric Davis on 25/11/2021.
//  Copyright © 2021 AppDev Training. All rights reserved.
//

import UserNotifications
import UIKit

struct Alarm {
    
    private var notificationId: String?
    
    var date: Date
    
    init(date: Date, notificationId: String? = nil) {
        self.date = date
        //if notification id == nil, then create a unique id for the notification
        self.notificationId = notificationId ?? UUID().uuidString
    }
    
    //MARK: Closure function
    //this is how you create a function that returns nothing
    func schedule(completion: @escaping (Bool) -> ()) {
        
        //if the user hasnt been prompted with the alert to allow or not allow notifications, then run authorize
        authorizeIfNeeded { (granted) in
            guard granted else {
                //run this if granted is false
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            //run this if granted is true
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Beep Beep"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = Alarm.notificationCategoryId
            
            //create the trigger
            let triggerDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: self.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            //create the request
            //since the notification id is created on the initialization, its safe to force unwrap notificationId
            let request = UNNotificationRequest(identifier: self.notificationId!, content: content, trigger: trigger)
            
            //add the notification to the user notification center
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func unschedule() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId!])
    }
    
    private func authorizeIfNeeded(completion: @escaping (Bool) -> ()) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, _) in
                    completion(granted)
                }
            case .denied, .provisional, .ephemeral:
                //.ephemeral is for app clips
                completion(false)
            }
        }
    }
}

extension Alarm: Codable {
    static let notificationCategoryId = "AlarmNotification"
    static let snoozeActionId = "snooze"
    
    private static let alarmURL: URL = {
        guard let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can't get URL for documents directory.")
        }
        
        return baseURL.appendingPathComponent("ScheduledAlarm")
    }()
    
    static var scheduled: Alarm? {
        get {
            guard let data = try? Data(contentsOf: alarmURL) else {return nil}
            
            return try? JSONDecoder().decode(Alarm.self, from: data)
        }
        
        set(newAlarm) {
            if let alarm = newAlarm {
                let data = try? JSONEncoder().encode(alarm)
                try? data?.write(to: alarmURL)
            } else {
                try? FileManager.default.removeItem(at: alarmURL)
            }
            
            NotificationCenter.default.post(name: Notification.Name.alarmUpdated, object: nil)
        }
    }
    
    
    
    
}
