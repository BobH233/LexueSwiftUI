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
        // NotificationCenter.default.addObserver(self, selector: #selector(notifyCloud(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    private func shouldSync(keyName: String, prefix: [String], specify: [String], blacklist: [String]) -> Bool {
        if blacklist.contains(keyName) {
            return false
        }
        if specify.contains(keyName) {
            return true
        }
        for pf in prefix {
            if keyName.hasPrefix(pf) {
                return true
            }
        }
        return false
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
        if let dict2 = notification.userInfo?["NSUbiquitousKeyValueStoreChangedKeysKey"] as? [String] {
            disableMonitor()
            for key in dict2 {
                if shouldSync(keyName: key) {
                    UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(dict[key], forKey: key)
                }
            }
            enableMonitor()
            NotificationCenter.default.post(name: iCloudUserDefaults.cloudSyncNotification, object: dict)
        }
    }
    
    func clearAllCloudStorage() {
        let dict = NSUbiquitousKeyValueStore.default.dictionaryRepresentation
        var toRemove = [String]()
        for (key, _) in dict {
            toRemove.append(key)
        }
        for key in toRemove {
            NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
        }
    }
    
    func SyncSome(prefix: [String] = [], specify: [String] = [], blacklist: [String] = []) {
        let dict = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.dictionaryRepresentation()
        for (key, value) in dict {
            if shouldSync(keyName: key, prefix: prefix, specify: specify, blacklist: blacklist) {
                NSUbiquitousKeyValueStore.default.set(value, forKey: key)
            }
        }
    }
    
    @objc internal func notifyCloud(notification: NSNotification) {
        // 不要自动监测了...还是有很多问题，直接改为在需要的地方手动上传吧...
//        let dict = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.dictionaryRepresentation()
//        for (key, value) in dict {
//            if shouldSync(keyName: key) {
//                NSUbiquitousKeyValueStore.default.set(value, forKey: key)
//            }
//        }
    }
}
