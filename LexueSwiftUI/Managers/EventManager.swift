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
    
    // 显示的今天之前的ddl，或者已经完成的ddl
    @Published var expiredEventDisplayList: [EventStored] = []
    // 从数据库加载缓存的事件列表
    func LoadEventList() {
        var result = DataController.shared.queryAllEventStored(context: DataController.shared.container.viewContext)
        // 排序，时间最早的在最前面
        result.sort{ (event1, event2) in
            let event1_date = event1.timestart ?? Date()
            let event2_date = event2.timestart ?? Date()
            return event1_date < event2_date
        }
        var tmp1 = [EventStored]()
        var tmp2 = [EventStored]()
        // 分组，已经完成的，或者过期的都放到expired组
        for event in result {
            let midnight_today = Calendar.current.startOfDay(for: .now)
            if event.finish {
                tmp2.append(event)
            } else if let startdate = event.timestart, startdate < midnight_today {
                tmp2.append(event)
            } else {
                tmp1.append(event)
            }
        }
        EventDisplayList = tmp1
        // 从最近到早排序
        expiredEventDisplayList = tmp2.reversed()
    }
    
    func FinishEvent(id: UUID, isFinish: Bool, context: NSManagedObjectContext) {
        let event = DataController.shared.findEventById(id: id, context: context)
        event?.finish = isFinish
        DataController.shared.save(context: context)
        LoadEventList()
    }
    
    // 对比新的事件列表，如果缓存没有则加入，如果缓存有则更新
    func DiffAndUpdateCacheEvent(_ newEvents: [LexueAPI.EventInfo]) {
        // print("DiffAndUpdateCacheEvent")
        for newEvent in newEvents {
            let tryFind = DataController.shared.findEventStoredByLexueId(lexue_event_id: newEvent.id, context: DataController.shared.container.viewContext)
            if let found = tryFind {
                print("Update event \(newEvent.id)")
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
                DataController.shared.save(context: DataController.shared.container.viewContext)
            } else {
                print("Add event \(newEvent.id)")
                DataController.shared.addEventStored(isCustomEvent: false, event_name: newEvent.name, event_description: newEvent.description, lexue_id: newEvent.id, timestart: newEvent.timestart, timeusermidnight: newEvent.timeusermidnight, mindaytimestamp: newEvent.mindaytimestamp, course_id: newEvent.course?.id, course_name: newEvent.course?.fullname, color: .green, action_url: newEvent.action_url, event_type: newEvent.eventtype, instance: Int64(newEvent.instance ?? 0), url: newEvent.url, context: DataController.shared.container.viewContext)
            }
        }
        LoadEventList()
    }
}
