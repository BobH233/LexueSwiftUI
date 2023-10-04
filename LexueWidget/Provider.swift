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
        return DefaultEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (DefaultEntry) -> ()) {
        // print("getSnapshot")
        let entry = DefaultEntry()
        completion(entry)
    }
    
    // 获取今天的事件总数
    func GetTodayEventCount(today: Date, events: [EventStored]) -> Int {
        var ret = 0
        for event in events {
            if EventManager.IsTodayEvent(event: event, today: today) {
                ret = ret + 1
            }
        }
        return ret
    }
    // 获取这一周的事件总数
    func GetWeekEventCount(todayInWeek: Date, events: [EventStored]) -> Int {
        var ret = 0
        for i in 0...7 {
            let target_date = Calendar.current.date(byAdding: .day, value: i, to: .now)!
            if target_date.isInSameWeek(as: .now) {
                ret = ret + GetTodayEventCount(today: target_date, events: events)
            }
        }
        return ret
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DefaultEntry>) -> ()) {
        print("getTimeline")
        
        var entry = DefaultEntry()
        entry.events = EventManager.shared.Widget_GetEventList()
        entry.day_event_count = GetTodayEventCount(today: Date(), events: entry.events)
        entry.week_event_count = GetWeekEventCount(todayInWeek: Date(), events: entry.events)
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60)))
        completion(timeline)
    }
}
