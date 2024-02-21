//
//  iOSCalendarManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/21.
//

import Foundation
import EventKit

class iOSCalendarManager {
    static let shared = iOSCalendarManager()
    var eventStore = EKEventStore()
    
    init() {
        
    }
    
    func IsCalendarExist(calendarName: String) async -> Bool {
        await withCheckedContinuation { continuation in
            eventStore.requestAccess(to: .event) { granted, error in
                guard granted, error == nil else {
                    continuation.resume(returning: false)
                    return
                }
                
                let calendars = self.eventStore.calendars(for: .event)
                let calendarExists = calendars.contains { $0.title == calendarName }
                continuation.resume(returning: calendarExists)
            }
        }
    }
    
    func AddNewCalendar(calendarName: String, calendarColor: UIColor, rewriteExist: Bool = false) async -> Bool {
        await withCheckedContinuation { continuation in
            eventStore.requestAccess(to: .event) { granted, error in
                guard granted, error == nil else {
                    continuation.resume(returning: false)
                    return
                }
                
                let calendars = self.eventStore.calendars(for: .event)
                if let existingCalendar = calendars.first(where: { $0.title == calendarName }) {
                    guard rewriteExist else {
                        print("repeat calendar ignore, continue")
                        continuation.resume(returning: true) // 如果不重写存在的日历，直接返回成功
                        return
                    }
                    
                    do {
                        print("repeat calendar remove origin")
                        try self.eventStore.removeCalendar(existingCalendar, commit: false)
                    } catch {
                        continuation.resume(returning: false)
                        return
                    }
                }
                
                let newCalendar = EKCalendar(for: .event, eventStore: self.eventStore)
                newCalendar.title = calendarName
                newCalendar.cgColor = calendarColor.cgColor
                if let source = self.eventStore.defaultCalendarForNewEvents?.source {
                    newCalendar.source = source
                } else {
                    continuation.resume(returning: false)
                    return
                }
                
                do {
                    try self.eventStore.saveCalendar(newCalendar, commit: true)
                    continuation.resume(returning: true)
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
}
