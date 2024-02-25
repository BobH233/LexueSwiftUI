//
//  ScheduleManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/22.
//
//  课程表管理相关

import Foundation
import CoreData

struct ScheduleSectionInfo: Codable {
    var sectionIndex: Int = 0
    var sectionStartDateStr: String = ""
    var sectionEndDateStr: String = ""
}



struct DailyScheduleInfo {
    var day_index: Int
    var courses_today: [JXZXehall.ScheduleCourseInfo]
    
    // 是否有课程开始于这个格子
    func HasCourseInSection(sectionId: Int) -> JXZXehall.ScheduleCourseInfo? {
        for course in courses_today {
            if course.StartSectionId == sectionId {
                return course
            }
        }
        return nil
    }
    
    func IsSectionFree(sectionId: Int) -> Bool {
        for course in courses_today {
            if sectionId >= course.StartSectionId && sectionId <= course.EndSectionId {
                return false
            }
        }
        return true
    }
}


class ScheduleManager {
    static let shared = ScheduleManager()
    // TODO: 学期更新时记得更新
    let default_semester_info = "2023-2024-2"
    let default_schedule_section_info: [ScheduleSectionInfo] = [
        ScheduleSectionInfo(sectionIndex: 1, sectionStartDateStr: "8:00", sectionEndDateStr: "8:45"),
        ScheduleSectionInfo(sectionIndex: 2, sectionStartDateStr: "8:50", sectionEndDateStr: "9:35"),
        ScheduleSectionInfo(sectionIndex: 3, sectionStartDateStr: "9:55", sectionEndDateStr: "10:40"),
        ScheduleSectionInfo(sectionIndex: 4, sectionStartDateStr: "10:45", sectionEndDateStr: "11:30"),
        ScheduleSectionInfo(sectionIndex: 5, sectionStartDateStr: "11:35", sectionEndDateStr: "12:20"),
        ScheduleSectionInfo(sectionIndex: 6, sectionStartDateStr: "13:20", sectionEndDateStr: "14:05"),
        ScheduleSectionInfo(sectionIndex: 7, sectionStartDateStr: "14:10", sectionEndDateStr: "14:55"),
        ScheduleSectionInfo(sectionIndex: 8, sectionStartDateStr: "15:15", sectionEndDateStr: "16:00"),
        ScheduleSectionInfo(sectionIndex: 9, sectionStartDateStr: "16:05", sectionEndDateStr: "16:50"),
        ScheduleSectionInfo(sectionIndex: 10, sectionStartDateStr: "16:55", sectionEndDateStr: "17:40"),
        ScheduleSectionInfo(sectionIndex: 11, sectionStartDateStr: "18:30", sectionEndDateStr: "19:15"),
        ScheduleSectionInfo(sectionIndex: 12, sectionStartDateStr: "19:20", sectionEndDateStr: "20:05"),
        ScheduleSectionInfo(sectionIndex: 13, sectionStartDateStr: "20:10", sectionEndDateStr: "20:55"),
    ]

    func SaveScheduleSectionInfo(current: [ScheduleSectionInfo]) {
        if let data = encodeFuncDescriptionStoredArr(current) {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(data, forKey: "stored.scheduleInfo")
            print("保存设置成功！")
        }
    }

    func GetScheduleSectionInfo() -> [ScheduleSectionInfo] {
        if let stored_data = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "stored.scheduleInfo") as? Data {
            let tmp: [ScheduleSectionInfo] = decodeStructArray(from: stored_data)
            return tmp
        } else {
            // 如果是第一次，那么返回默认信息
            return default_schedule_section_info
        }
    }
    
    func SaveSemesterInfo(current: String) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(current, forKey: "stored.semesterInfo")
    }
    
    func GetSemesterInfo() -> String {
        if let stored_data = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "stored.semesterInfo") as? String {
            return stored_data
        } else {
            // 如果是第一次，那么返回默认信息
            return default_semester_info
        }
    }
    
    // 从乐学后端获取课程表节数信息，并缓存
    private func UpdateSectionInfo() async {
        let backendResult = await LexueHelperBackend.shared.GetScheduleSectionInfo()
        if backendResult.count > 0 {
            SaveScheduleSectionInfo(current: backendResult)
            print("成功更新课程表节数信息", backendResult)
        }
    }
    // 更新当前学期标识，并缓存
    private func UpdateSemesterInfo() async {
        let backendResult = await LexueHelperBackend.shared.GetScheduleSemesterInfo()
        if !backendResult.isEmpty {
            SaveSemesterInfo(current: backendResult)
            print("成功更新学期信息", backendResult)
        }
    }
    // 更新所有课程表信息
    func UpdateScheduleInfo() async {
        await UpdateSectionInfo()
        await UpdateSemesterInfo()
    }
    
    func GetCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/M/d"
        let todayDateString = dateFormatter.string(from: Date())
        return todayDateString
    }
    
    // 获取本地存储的课表的第一天开学时间，如果本地没存储课程表，则返回nil
    func GetFirstDateOfLocalSchedule(context: NSManagedObjectContext) -> Date? {
        let request: NSFetchRequest<ScheduleCourseStored> = ScheduleCourseStored.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "importDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        do {
            // 执行fetch请求
            let result = try context.fetch(request)
            if let maxRecord = result.first {
                return maxRecord.semesterStartDate
            } else {
                return nil
            }
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getMondayOfCurrentWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 将星期一设置为每周的第一天
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        // 计算从今天到本周一的天数差
        var daysToMonday = -((weekday - calendar.firstWeekday - 1 + 7) % 7)
        // 如果今天是星期日，则特殊处理，直接回溯到上周的星期一
        if weekday == 1 {
            daysToMonday = -6
        }

        let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)!
        return monday
    }

    
    // 获取课程表第一周星期一应该显示哪一天，如果有GetFirstDateOfLocalSchedule，且这个日期在今天之前，则第一天应该显示学期开始的第一天
    // 如果没有 GetFirstDateOfLocalSchedule 或者 GetFirstDateOfLocalSchedule 还没到来，则显示当前这一周
    func GetScheduleDisplayFirstWeek(context: NSManagedObjectContext) -> Date {
        if let firstSemesterDate = GetFirstDateOfLocalSchedule(context: context) {
            let today = Date.now
            if compareDatesIgnoringTime(today, firstSemesterDate) == .orderedDescending {
                // 今天在学期第一天之后，所以应该返回学期第一天
                return firstSemesterDate
            }
        }
        // 学期还没开始，返回这周一的日期
        return getMondayOfCurrentWeek()
    }
    
    // 获取以第一周时间为准往后的n周的信息
    func GetWeekDisplayInfo(firstWeek: Date, targetWeekIndex: Int) -> (String, [String], [Date]) {
        let calendar = Calendar.current
        var ret_arr: [String] = []
        var ret_date_arr: [Date] = []
        guard let start = calendar.date(byAdding: .day, value: 7 * targetWeekIndex, to: firstWeek) else {
            return ("错误", ["","","","","","",""], [Date.now,Date.now,Date.now,Date.now,Date.now,Date.now,Date.now])
        }
        let ret_month = "\(calendar.component(.month, from: start))月"
        for i in 0..<7 {
            guard let now = calendar.date(byAdding: .day, value: i, to: start) else {
                return ("错误", ["","","","","","",""], [Date.now,Date.now,Date.now,Date.now,Date.now,Date.now,Date.now])
            }
            ret_arr.append("\(calendar.component(.day, from: now))")
            ret_date_arr.append(now)
        }
        return (ret_month, ret_arr, ret_date_arr)
    }
    
    // 获取是否是当前周
    func GetWeekDesText(context: NSManagedObjectContext, selectionWeekIndex: Int) -> String {
        let calendar = Calendar.current
        let firstDate = GetScheduleDisplayFirstWeek(context: context)
        guard let selectionWeekMonday = calendar.date(byAdding: .day, value: 7 * selectionWeekIndex, to: firstDate) else {
            return ""
        }
        guard let selectionNextWeekMonday = calendar.date(byAdding: .day, value: 7 * (selectionWeekIndex + 1), to: firstDate) else {
            return ""
        }
        guard let selectionPrevWeekMonday = calendar.date(byAdding: .day, value: 7 * (selectionWeekIndex - 1), to: firstDate) else {
            return ""
        }
        if compareDatesIgnoringTime(selectionWeekMonday, getMondayOfCurrentWeek()) == .orderedSame {
            return "当前周"
        }
        if compareDatesIgnoringTime(selectionPrevWeekMonday, getMondayOfCurrentWeek()) == .orderedSame {
            return "下一周"
        }
        if compareDatesIgnoringTime(selectionNextWeekMonday, getMondayOfCurrentWeek()) == .orderedSame {
            return "上一周"
        }
        return ""
    }
    
}


