//
//  Provider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import UserNotifications

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DefaultEntry {
        // print("placeholder")
        return DefaultEntry(date: Date(), str: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (DefaultEntry) -> ()) {
        // print("getSnapshot")
        let entry = DefaultEntry(date: .now, str: "lalallala")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DefaultEntry>) -> ()) {
        print("getTimeline")
        print(SettingStorage.shared.loginnedContext)
        print(SettingStorage.shared.cacheUserInfo)
        let entry = DefaultEntry(date: .now, str: "lalallala2")
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60)))
        completion(timeline)
//        let identifier = UUID().uuidString
//        let content = UNMutableNotificationContent()
//        content.title = "\(Date.now)"
//        content.body = "widget info!"
//        content.userInfo = ["123":"1234"]
//        content.sound = .default
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(0.01), repeats: false)
//        let request = UNNotificationRequest(
//            identifier: identifier,
//            content: content,
//            trigger: trigger
//        )
//        UNUserNotificationCenter.current().add(request) { error in
//            if error == nil {
//                // print("消息通知已设定: \(identifier)")
//            }
//        }
//        
//        let entry = DefaultEntry(date: .now, str: "lalallala2")
//        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60)))
//        completion(timeline)
    }
}
