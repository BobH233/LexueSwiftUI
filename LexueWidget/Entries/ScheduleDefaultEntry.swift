//
//  ScheduleDefaultEntry.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2024/3/1.
//

import WidgetKit

struct ScheduleDefaultEntry: TimelineEntry {
    var date: Date = Date()
    var size: CGSize = CGSize()
    var isLogin: Bool = false
    var today_courses: [JXZXehall.ScheduleCourseInfo] = []
    var tomorrow_courses: [JXZXehall.ScheduleCourseInfo] = []
    var isSemesterEnd: Bool = false
}

extension ScheduleDefaultEntry {
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
