//
//  LocalNotificationManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/27.
//

import Foundation
import UserNotifications
import Foundation
import SwiftUI

class LocalNotificationManager: ObservableObject {
    static let shared = LocalNotificationManager()
    
    @Published var isAllowNotification: Bool = false
    
    func RequestPermission() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    print("授予通知权限")
                    self.isAllowNotification = true
                } else {
                    print("未授予通知权限")
                    self.isAllowNotification = false
                    print(error)
                }
            }
    }
    
    func GuardNotificationPermission(authorizedCB: @escaping () -> Void = {}) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("已授权，用户允许通知")
                self.isAllowNotification = true
                // 注册远程通知，获取设备deviceId
                authorizedCB()
            case .notDetermined:
                self.RequestPermission()
            case .denied:
                print("用户不允许消息通知")
                self.isAllowNotification = false
            @unknown default:
                return
            }
        }
    }
    
    func PushNotification(title: String, body: String, userInfo: [AnyHashable : Any], image: UIImage? = nil, interval: Double = 5) {
        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = userInfo
        content.sound = .default
        if let image = image, let attachment = UNNotificationAttachment.create(identifier: identifier, image: image, options: nil) {
            content.attachments = [attachment]
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                // print("消息通知已设定: \(identifier)")
            }
        }
    }
}
