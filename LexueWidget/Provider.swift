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
        var ret = DefaultEntry()
        ret.isLogin = true
        return ret
    }

    func getSnapshot(in context: Context, completion: @escaping (DefaultEntry) -> ()) {
        var entry = DefaultEntry()
        entry.isLogin = true
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
        for event in events {
            for i in 0...7 {
                let target_date = Calendar.current.date(byAdding: .day, value: i, to: .now)!
                if !target_date.isInSameWeek(as: .now) {
                    continue
                }
                if EventManager.IsTodayEvent(event: event, today: target_date) {
                    ret = ret + 1
                    break
                }
            }
        }
        return ret
    }
    
    // 更新 eventlist
    func UpdateEventList() async throws {
        var recent_events:[LexueAPI.EventInfo] = []
//        for i in -3 ... 7 {
//            let currentDate = Date()
//            let target_date = Calendar.current.date(byAdding: .day, value: i, to: currentDate)
//            let target_date_comp = Calendar.current.dateComponents([.year, .month, .day], from: target_date!)
//            let tmpRes = try await LexueAPI.shared.GetEventsByDay(GlobalVariables.shared.cur_lexue_context, sesskey: GlobalVariables.shared.cur_lexue_sessKey, year: String(target_date_comp.year!), month: String(target_date_comp.month!), day: String(target_date_comp.day!))
//            switch tmpRes {
//            case .success(let events):
//                recent_events.append(contentsOf: events)
//            case .failure(_):
//                print("fail to fetch \(target_date_comp)")
//            }
//        }
        for i in 0 ... 1 {
            let currentDate = Date()
            let target_date = Calendar.current.date(byAdding: .month, value: i, to: currentDate)
            let target_date_comp = Calendar.current.dateComponents([.year, .month, .day], from: target_date!)
            let tmpRes = try await LexueAPI.shared.GetEventsByMonth(GlobalVariables.shared.cur_lexue_context, sesskey: GlobalVariables.shared.cur_lexue_sessKey, year: String(target_date_comp.year!), month: String(target_date_comp.month!))
            switch tmpRes {
            case .success(let events):
                recent_events.append(contentsOf: events)
            case .failure(_):
                print("fail to fetch \(target_date_comp)")
            }
        }
        await DataController.shared.container.performBackgroundTask { (context) in
            EventManager.shared.DiffAndUpdateCacheEvent(recent_events, context: context)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DefaultEntry>) -> ()) {
        print("getTimeline")
        var entry = DefaultEntry()
        entry.events = EventManager.shared.Widget_GetEventList()
        entry.day_event_count = GetTodayEventCount(today: Date(), events: entry.events)
        entry.week_event_count = GetWeekEventCount(todayInWeek: Date(), events: entry.events)
        print(context.displaySize)
        entry.size = context.displaySize
        // 从app读入正确的令牌
        GlobalVariables.shared.cur_lexue_context = SettingStorage.shared.get_widget_shared_LexueContext()
        GlobalVariables.shared.cur_lexue_sessKey = SettingStorage.shared.get_widget_shared_sesskey()
        if GlobalVariables.shared.cur_lexue_context.MoodleSession ==  "" {
            entry.isLogin = false
        } else {
            entry.isLogin = true
        }
        // 预计10分钟再刷新一次
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 10 * 60)))
        let nowTime = Date.now.timeIntervalSince1970
        let lastAppRefresh = SettingStorage.shared.get_widget_shared_AppActiveDate()
        if entry.isLogin && nowTime - lastAppRefresh > 60 * 2 {
            // 完成app的事件刷新
            // 只在app在前台不响应超过2分钟才刷新
            SettingStorage.shared.set_widget_shared_AppActiveDate(nowTime)
            Task(timeout: 50) {
                do {
                    try await UpdateEventList()
                    print("Refreshing data providers...")
                    await DataProviderManager.shared.DoRefreshAll(param: ["userId": SettingStorage.shared.cacheUserInfo.userId])
                } catch {
                    print("刷新消息超时!")
                }
                completion(timeline)
            }
        } else {
            completion(timeline)
        }
    }
}
