//
//  AppNotificationsManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/29.
//

// App的公告消息管理类


import Foundation

class AppNotificationsManager: ObservableObject {
    static let shared = AppNotificationsManager()
    @Published var notificationsList: [LexueHelperBackend.AppNotification] = []
    @Published var hasNewNotifications: Bool = false
    
    var readPopupId: [Int: Bool] = [:]
    
    @Published var popupNotificationQueue: [LexueHelperBackend.AppNotification] = []
    @Published var showPopupSheet: Bool = false
    
    init() {
        GetReadPopupId()
    }
    
    func GetReadPopupId() {
        if let data = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.data(forKey: "appnotifications.readPopupId"), let saveData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Int: Bool] {
            readPopupId = saveData
        } else {
            readPopupId = [:]
        }
    }
    
    func GetMaxId() -> Int {
        var maxId = 0
        for notification in notificationsList {
            maxId = max(maxId, notification.notificationId)
        }
        return maxId
    }
    
    func SetReadPopupId(id: Int) {
        readPopupId[id] = true
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: readPopupId, requiringSecureCoding: false) {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(data, forKey: "appnotifications.readPopupId")
        }
        DispatchQueue.main.async {
            self.popupNotificationQueue.removeAll { notification in
                return notification.notificationId == id
            }
            if self.popupNotificationQueue.count == 0 {
                self.showPopupSheet = false
            }
        }
        
    }
    
    func GetReadLastestId() -> Int {
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "appnotifications.readlatestid") as? Int {
            return stored
        } else {
            return -1
        }
    }
    
    func SetReadLatestId(id: Int) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(id, forKey: "appnotifications.readlatestid")
        DispatchQueue.main.async {
            var hasNewMessage = false
            for notification in self.notificationsList {
                let readId = self.GetReadLastestId()
                if notification.notificationId > readId {
                    hasNewMessage = true
                    break
                }
            }
            self.hasNewNotifications = hasNewMessage
        }
    }
    
    func UpdateNotifications() async {
        let res = await LexueHelperBackend.shared.FetchAppNotifications()
        DispatchQueue.main.async {
            self.notificationsList = res
            self.notificationsList.sort { noti1, noti2 in
                let pin1 = noti1.pinned ? 1 : 0
                let pin2 = noti2.pinned ? 1 : 0
                if pin1 != pin2 {
                    return pin1 > pin2
                } else {
                    return noti1.GetDate() > noti2.GetDate()
                }
            }
        }
        // 判断是否有新的消息, 是否有需要显示的弹窗消息
        let readId = GetReadLastestId()
        DispatchQueue.main.async {
            var hasNewMessage = false
            for notification in res {
                if notification.notificationId > readId {
                    hasNewMessage = true
                    break
                }
            }
            self.hasNewNotifications = hasNewMessage
            for notification in res {
                if notification.isPopupNotification && self.readPopupId[notification.notificationId] == nil {
                    self.popupNotificationQueue.append(notification)
                }
            }
            if self.popupNotificationQueue.count > 0 {
                self.showPopupSheet = true
            }
        }
    }
}
