//
//  KumpeAPNS.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/16/20.
//

import Foundation
import UIKit
import UserNotifications

protocol KumpeAPNS: UNUserNotificationCenterDelegate {
    func registerForPushNotifications()
    func getNotificationSettings()
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    )
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    )
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    )
    func apsAction(_ action: String, _ aps: [String: AnyObject])
}

extension KumpeAPNS {
        
    //    MARK: registerForPushNotifications
        func registerForPushNotifications() {
            UNUserNotificationCenter.current()
              .requestAuthorization(
                options: [.alert, .sound, .badge, .announcement]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
              }

            
        }


    //    MARK: getNotificationSettings
        func getNotificationSettings() {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
              UIApplication.shared.registerForRemoteNotifications()
            }

          }
        }

    //    MARK: application: didRegisterForRemoteNotificationsWithDeviceToken
        func application(
          _ application: UIApplication,
          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
          let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
          let token = tokenParts.joined()
          print("Device Token: \(token)")
            UserDefaults.standard.set(token, forKey: "apnsToken")
        }

    //    MARK: application: didFailToRegisterForRemoteNotificationsWithError
        func application(
          _ application: UIApplication,
          didFailToRegisterForRemoteNotificationsWithError error: Error
        ) {
          print("Failed to register: \(error)")
        }
        
        func application(
          _ application: UIApplication,
          didReceiveRemoteNotification userInfo: [AnyHashable: Any],
          fetchCompletionHandler completionHandler:
          @escaping (UIBackgroundFetchResult) -> Void
        ) {
            
          guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
          }
            dispatchOnBackground {
                guard let action:String = aps["action"] as? String else{
                    return
                }
                self.apsAction(action,aps)
            }
            completionHandler(.newData)
        }
}
