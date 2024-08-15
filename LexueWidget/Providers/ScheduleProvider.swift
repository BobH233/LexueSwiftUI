//
//  ScheduleProvider.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2024/3/1.
//

import WidgetKit

struct ScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleDefaultEntry {
        var ret = ScheduleDefaultEntry()
        ret.isLogin = true
        return ret
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleDefaultEntry) -> ()) {
        var entry = ScheduleDefaultEntry()
        entry.isLogin = true
        completion(entry)
    }
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleDefaultEntry>) -> ()) {
        print("getTimeline")
        var entry = ScheduleDefaultEntry()
        let db_context = DataController.shared.container.viewContext
        let (semesterSchedule, weekOffset) = ScheduleManager.shared.GenerateAllWeekScheduleInSemester(context: db_context)
        let calendar = Calendar.current
        
        let today_in_week = ScheduleManager.shared.GetCurrentWeekSelection(context: db_context, nowDate: .now)
        let today_index = (calendar.component(.weekday, from: .now) - 2 + 7) % 7
        let tomorrow_in_week = ScheduleManager.shared.GetCurrentWeekSelection(context: db_context, nowDate: calendar.date(byAdding: .day, value: 1, to: .now)!)
        let tomorrow_index = (calendar.component(.weekday, from: calendar.date(byAdding: .day, value: 1, to: .now)!) - 2 + 7) % 7
        entry.date = .now
        entry.size = context.displaySize
        GlobalVariables.shared.cur_lexue_context = SettingStorage.shared.get_widget_shared_LexueContext()
        GlobalVariables.shared.cur_lexue_sessKey = SettingStorage.shared.get_widget_shared_sesskey()
        if GlobalVariables.shared.cur_lexue_context.MoodleSession ==  "" {
            entry.isLogin = false
        } else {
            entry.isLogin = true
        }
        if today_in_week - 1 >= semesterSchedule.count {
            entry.isSemesterEnd = true
        } else {
            entry.today_courses = semesterSchedule[today_in_week-1][today_index].courses_today.sorted { course1, course2 in
                return course1.StartSectionId < course2.StartSectionId
            }
        }
        if tomorrow_in_week - 1 >= semesterSchedule.count {
//            entry.isSemesterEnd = true
        } else {
            entry.tomorrow_courses = semesterSchedule[tomorrow_in_week-1][tomorrow_index].courses_today.sorted { course1, course2 in
                return course1.StartSectionId < course2.StartSectionId
            }
        }
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 10 * 60)))
        completion(timeline)
    }
}
