//
//  EventManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/1.
//

import Foundation
import CoreData

class EventManager: ObservableObject {
    static let shared = EventManager()
    
    // 显示的待完成的ddl
    @Published var EventDisplayList: [EventStored] = []
    
    @Published var DeletedEventDisplayList: [EventStored] = []
    
    // 显示的今天之前的ddl，或者已经完成的ddl
    @Published var expiredEventDisplayList: [EventStored] = []
    
    // 获取今天的事件总数
    func GetTodayEventCount(today: Date) -> Int {
        var ret = 0
        for event in EventDisplayList {
            if EventManager.IsTodayEvent(event: event, today: today) {
                ret = ret + 1
            }
        }
        return ret
    }
    // 获取这一周的事件总数
    func GetWeekEventCount(todayInWeek: Date) -> Int {
        var ret = 0
        for i in 0...7 {
            let target_date = Calendar.current.date(byAdding: .day, value: i, to: .now)!
            // print(target_date)
            if target_date.isInSameWeek(as: .now) {
                ret = ret + GetTodayEventCount(today: target_date)
            }
        }
        return ret
    }
    
    
    // 删除所有过期了的事件
    func DeleteAllExpiredEvent(context: NSManagedObjectContext = DataController.shared.container.viewContext) {
        var result = DataController.shared.queryAllEventStored(isDeleted: false, context: context)
        for event in result {
            let now_time = Date()
            if let startdate = event.timestart, startdate < now_time {
                event.user_deleted = true
            }
        }
        DataController.shared.save(context: context)
    }
    
    func LoadDeletedEventList(context: NSManagedObjectContext = DataController.shared.container.viewContext) {
        var result = DataController.shared.queryAllEventStored(isDeleted: true, context: context)
        // 排序，时间最晚的在最前面
        result.sort{ (event1, event2) in
            let event1_date = event1.timestart ?? Date()
            let event2_date = event2.timestart ?? Date()
            return event1_date > event2_date
        }
        DeletedEventDisplayList = result
    }
    
    // 从数据库加载缓存的事件列表
    func LoadEventList(context: NSManagedObjectContext = DataController.shared.container.viewContext) {
        var result = DataController.shared.queryAllEventStored(isDeleted: false, context: context)
        // 排序，时间最早的在最前面
        result.sort{ (event1, event2) in
            let event1_date = event1.timestart ?? Date()
            let event2_date = event2.timestart ?? Date()
            return event1_date < event2_date
        }
        var tmp1 = [EventStored]()
        var tmp2 = [EventStored]()
        
        let now_time = Date()
        // 分组，已经完成的，或者过期的都放到expired组
        for event in result {
            if event.finish {
                tmp2.append(event)
            } else if let startdate = event.timestart, startdate < now_time {
                tmp2.append(event)
            } else {
                tmp1.append(event)
            }
        }
        EventDisplayList = tmp1
        // 从最近到早排序
        expiredEventDisplayList = tmp2.reversed()
    }
    
    // 小组件专用的获取事件列表
    func Widget_GetEventList(context: NSManagedObjectContext = DataController.shared.container.viewContext) -> [EventStored] {
        var result = DataController.shared.queryAllEventStored(isDeleted: false, context: context)
        // 排序，时间最早的在最前面
        result.sort{ (event1, event2) in
            let event1_date = event1.timestart ?? Date()
            let event2_date = event2.timestart ?? Date()
            return event1_date < event2_date
        }
        var tmp1 = [EventStored]()
        let now_time = Date()
        for event in result {
            if let startdate = event.timestart, startdate >= now_time, !event.finish {
                tmp1.append(event)
            }
        }
        return tmp1
    }
    
    func FinishEvent(id: UUID, isFinish: Bool, context: NSManagedObjectContext) {
        let event = DataController.shared.findEventById(id: id, context: context)
        event?.finish = isFinish
        DispatchQueue.main.async {
            DataController.shared.save(context: context)
            self.LoadEventList(context: context)
        }
    }
    
    // 判断是否是属于今天的ddl的逻辑，注意次日的凌晨的ddl也要考虑，现在暂时先这样写
    static func IsTodayEvent(event: EventStored, today: Date) -> Bool {
        
        
        let setting_value = SettingStorage.shared.event_midnightFixTime
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)
        let targetDate = event.timestart!
        if let todayAM = calendar.date(bySettingHour: setting_value, minute: 0, second: 0, of: startOfToday), let nextDayAM = calendar.date(byAdding: .day, value: 1, to: todayAM) {
            // 如果本来就是今天，也得算今天，比如我现在0点了，但是还要赶5点的ddl，这个不能算到昨天里面
            if targetDate > startOfToday && targetDate <= nextDayAM {
                return true
            }
        }
        return false
    }
    
    // 对比新的事件列表，如果缓存没有则加入，如果缓存有则更新
    func DiffAndUpdateCacheEvent(_ newEvents: [LexueAPI.EventInfo], context: NSManagedObjectContext = DataController.shared.container.viewContext) {
        DataController.shared.container.performBackgroundTask { (context) in
            for newEvent in newEvents {
                let tryFind = DataController.shared.findEventStoredByLexueId(lexue_event_id: newEvent.id, context: context)
                if let found = tryFind {
                    // print("Update event \(newEvent.id)")
                    found.action_url = newEvent.action_url
                    found.course_id = newEvent.course?.id
                    found.course_name = newEvent.course?.fullname
                    found.event_description = newEvent.description
                    found.event_type = newEvent.eventtype
                    found.instance = Int64(newEvent.instance ?? 0)
                    found.isCustomEvent = false
                    found.mindaytimestamp = newEvent.mindaytimestamp
                    found.name = newEvent.name
                    found.timestart = newEvent.timestart
                    found.timeusermidnight = newEvent.timeusermidnight
                    found.url = newEvent.url
                    DataController.shared.save(context: context)
                } else {
                    // print("add event \(newEvent.id)")
                    DataController.shared.addEventStored(isCustomEvent: false, event_name: newEvent.name, event_description: newEvent.description, lexue_id: newEvent.id, timestart: newEvent.timestart, timeusermidnight: newEvent.timeusermidnight, mindaytimestamp: newEvent.mindaytimestamp, course_id: newEvent.course?.id, course_name: newEvent.course?.fullname, color: .green, action_url: newEvent.action_url, event_type: newEvent.eventtype, instance: Int64(newEvent.instance ?? 0), url: newEvent.url, context: context)
                }
            }
            DispatchQueue.main.async {
                self.LoadEventList()
            }
        }
    }
}
