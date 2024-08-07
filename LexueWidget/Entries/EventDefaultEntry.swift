//
//  DefaultEntry.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//


import WidgetKit

struct EventDefaultEntry: TimelineEntry {
    var date: Date = Date()
    var size: CGSize = CGSize()
    var isLogin: Bool = false
    var day_event_count: Int = 0
    var week_event_count: Int = 0
    var events: [EventStored] = []
}

extension EventDefaultEntry {
    func GetDayText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M.d"
        return dateFormatter.string(from: date)
    }
    func GetWeekdayText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}
