//
//  iCloudUserDefaults.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/28.
//

import Foundation

class iCloudUserDefaults {
    static let shared = iCloudUserDefaults()
    
    public static let cloudSyncNotification = Notification.Name("CloudSyncNotification")
    
    var monitored_prefix: [String] = []
    
    var monitored_specify: [String] = []
    
    var monitored_blacklist: [String] = []
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFromCloud(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyCloud(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    private func shouldSync(keyName: String) -> Bool {
        if monitored_blacklist.contains(keyName) {
            return false
        }
        if monitored_specify.contains(keyName) {
            return true
        }
        for allow_prefix in monitored_prefix {
            if keyName.hasPrefix(allow_prefix) {
                return true
            }
        }
        return false
    }
    
    func disableMonitor() {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func enableMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(notifyCloud(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc internal func notificationFromCloud(notification: NSNotification) {
        let dict = NSUbiquitousKeyValueStore.default.dictionaryRepresentation
        disableMonitor()
        for (key, value) in dict {
            if shouldSync(keyName: key) {
                UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(value, forKey: key)
            }
        }
        enableMonitor()
        NotificationCenter.default.post(name: iCloudUserDefaults.cloudSyncNotification, object: dict)
    }
    @objc internal func notifyCloud(notification: NSNotification) {
        let dict = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.dictionaryRepresentation()
        for (key, value) in dict {
            if shouldSync(keyName: key) {
                NSUbiquitousKeyValueStore.default.set(value, forKey: key)
            }
        }
    }
}
