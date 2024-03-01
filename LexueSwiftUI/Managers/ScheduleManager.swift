//
//  ScheduleManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/22.
//
//  课程表管理相关

import Foundation
import CoreData
import SwiftUI

struct ScheduleSectionInfo: Codable {
    var sectionIndex: Int = 0
    var sectionStartDateStr: String = ""
    var sectionEndDateStr: String = ""
    func GetStartDateCp() -> (Int, Int) {
        let components = sectionStartDateStr.split(separator: ":")
        if components.count == 2 {
            return (Int(components[0]) ?? 0, Int(components[1]) ?? 0)
        }
        return (0, 0)
    }
    func GetEndDateCp() -> (Int, Int) {
        let components = sectionEndDateStr.split(separator: ":")
        if components.count == 2 {
            return (Int(components[0]) ?? 0, Int(components[1]) ?? 0)
        }
        return (0, 0)
    }
    func GetIsDateInSection(date: Date = Date()) -> Bool {
        let (startHour, startMinute) = GetStartDateCp()
        let (endHour, endMinute) = GetEndDateCp()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        if let hour = components.hour, let minute = components.minute {
            let dateHourMinute = hour * 60 + minute
            let startDateHourMinute = startHour * 60 + startMinute
            let endDateHourMinute = endHour * 60 + endMinute
            
            if startDateHourMinute <= dateHourMinute && dateHourMinute <= endDateHourMinute {
                return true
            }
        }
        
        return false
    }
}

let refreshScheduleListNotification = Notification.Name("refreshScheduleListNotification")

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
    
    private func getMondayOfCurrentWeek(nowDate: Date = .now) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: nowDate)
        comps.weekday = 2 // Monday
        let mondayInWeek = cal.date(from: comps)!
        return mondayInWeek
    }

    
    // 获取课程表第一周星期一应该显示哪一天，如果有GetFirstDateOfLocalSchedule，且这个日期在今天之前，则第一天应该显示学期开始的第一天
    // 如果没有 GetFirstDateOfLocalSchedule 或者 GetFirstDateOfLocalSchedule 还没到来，则显示当前这一周
    func GetScheduleDisplayFirstWeek(context: NSManagedObjectContext) -> Date {
        print("getMondayOfCurrentWeek", getMondayOfCurrentWeek())
        if let firstSemesterDate = GetFirstDateOfLocalSchedule(context: context) {
            let today = Date.now
            if compareDatesIgnoringTime(today, firstSemesterDate) == .orderedDescending || compareDatesIgnoringTime(today, firstSemesterDate) == .orderedSame {
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
    func GetWeekDesText(context: NSManagedObjectContext, selectionWeekIndex: Int, firstDateProvided: Date? = nil) -> String {
        let calendar = Calendar.current
        let firstDate = firstDateProvided ?? GetScheduleDisplayFirstWeek(context: context)
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
    
    // 按照课程号去重课程，用于显示导入课程
    func GetUniqueScheduleCourseInfo(allInfo: [JXZXehall.ScheduleCourseInfo]) -> [JXZXehall.ScheduleCourseInfo] {
        // 使用字典去重，保持插入顺序
        let uniqueCourses = allInfo.reduce(into: [String: JXZXehall.ScheduleCourseInfo]()) { (result, courseInfo) in
            // 如果该课程号还未添加到结果中，则添加之
            if result[courseInfo.CourseId] == nil {
                result[courseInfo.CourseId] = courseInfo
            }
        }
        // 返回去重后的课程数组
        return Array(uniqueCourses.values)
    }
    
    // 存储当前的课程表
    func SaveScheduleCourseToLocal(context: NSManagedObjectContext, allInfo: [JXZXehall.ScheduleCourseInfo], semesterStartDate: Date, coverAll: Bool = true) {
        if coverAll {
            // 先把现存的课程表全部删除了
            DataController.shared.deleteEntityAllData(entityName: ScheduleCourseStored.entity().name ?? "", context: context)
        }
        let importDate = Date.now
        
        for var course in allInfo {
            course.ImportDate = importDate
            course.SemesterStartDate = semesterStartDate
            course.CourseBgColor = GetStringColor(str: course.CourseName)
            DataController.shared.AddScheduleCourseStored(context: context, scheduleInfo: course)
        }
        DataController.shared.save(context: context)
    }
    
    func GetValidCourse(context: NSManagedObjectContext) -> ([JXZXehall.ScheduleCourseInfo], Bool) {
        // 从数据库查询所有存储的课程，并只过滤importDate最新的
        let request: NSFetchRequest<ScheduleCourseStored> = ScheduleCourseStored.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "importDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        var latestImportDate: Date = .now
        var allCourseValid: [JXZXehall.ScheduleCourseInfo] = []
        do {
            // 执行fetch请求
            let result = try context.fetch(request)
            if let maxRecord = result.first {
                latestImportDate = maxRecord.importDate ?? .now
            } else {
                return ([], true)
            }
            for course in result {
                if course.importDate == latestImportDate {
                    allCourseValid.append(course.ToScheduleCourseInfo())
                }
            }
            return (allCourseValid, true)
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            return ([], false)
        }
    }
    
    // 生成总的课表，所有周的课程表
    func GenerateAllWeekScheduleInSemester(context: NSManagedObjectContext, firstDateProvided: Date? = nil) -> ([[DailyScheduleInfo]], Int) {
        var allCourseValid: [JXZXehall.ScheduleCourseInfo] = []
        var success: Bool = false
        (allCourseValid, success) = GetValidCourse(context: context)
        var semesterStartDate: Date = .now
        let calendar = Calendar.current
        if allCourseValid.count == 0 || !success {
            return ([[
                .init(day_index: 1, courses_today: []),
                .init(day_index: 2, courses_today: []),
                .init(day_index: 3, courses_today: []),
                .init(day_index: 4, courses_today: []),
                .init(day_index: 5, courses_today: []),
                .init(day_index: 6, courses_today: []),
                .init(day_index: 7, courses_today: [])
            ]],0)
        }
        semesterStartDate = allCourseValid.first!.SemesterStartDate
        
        
        // 先获取从学期开始，最大的有多少周
        var maxWeekCount = 0
        for course in allCourseValid {
            maxWeekCount = max(maxWeekCount, course.ExistWeek.count)
        }
        print("maxWeekCount: ", maxWeekCount)
        // 计算一下从当前日程表的第一周到开学周，有多少偏移
        let firstDate = firstDateProvided ?? GetScheduleDisplayFirstWeek(context: context)
        var offsetWeekToSemesterStart = 0
        for i in 0..<maxWeekCount {
            guard let offsetWeekDate = calendar.date(byAdding: .day, value: 7 * i, to: firstDate) else {
                continue
            }
            if compareDatesIgnoringTime(offsetWeekDate, semesterStartDate) == .orderedSame {
                offsetWeekToSemesterStart = i
                break
            }
        }
        print("offsetWeekToSemesterStart:", offsetWeekToSemesterStart)
        
        // 新建最终的课程表结构
        var retWeekSchedule: [[DailyScheduleInfo]] = [[DailyScheduleInfo]]()
        for _ in 0..<(maxWeekCount + offsetWeekToSemesterStart) {
            retWeekSchedule.append([])
            for i in 1...7 {
                retWeekSchedule[retWeekSchedule.count-1].append(.init(day_index: i, courses_today: []))
            }
        }
        // 处理每一门课程的情况
        for course in allCourseValid {
            for (index, character) in course.ExistWeek.enumerated() {
                if character == "1" {
                    retWeekSchedule[offsetWeekToSemesterStart + index][course.DayOfWeek - 1].courses_today.append(course)
                }
            }
        }
        return (retWeekSchedule, offsetWeekToSemesterStart)
    }
    
    // 获取当前日期应该选择哪一周
    func GetCurrentWeekSelection(context: NSManagedObjectContext, firstDateProvided: Date? = nil) -> Int {
        let firstDate = firstDateProvided ?? GetScheduleDisplayFirstWeek(context: context)
        let calendar = Calendar.current
        for i in 0..<30 {
            guard let offsetWeekDate = calendar.date(byAdding: .day, value: 7 * i, to: firstDate) else {
                continue
            }
            
            if compareDatesIgnoringTime(offsetWeekDate, getMondayOfCurrentWeek()) == .orderedSame {
                return i + 1
            }
        }
        return 1
    }
    
    struct CalendarEvent {
        var title: String = ""  // e.g. 课程名
        var location: String = ""  // e.g. 良乡校区理教楼308 xxx老师
        var StartDate: Date = .now
        var EndDate: Date = .now
        var note: String = ""  // 备注，显示上课地点+上课时间+老师
    }
    
    private func SetDate(toSet: Date, value: (Int, Int)) -> Date {
        var ret = toSet
        let calendar = Calendar.current
        ret = calendar.date(bySetting: .hour, value: value.0, of: ret)!
        ret = calendar.date(bySetting: .minute, value: value.1, of: ret)!
        return ret
    }
    
    func GenerateCalendarEvents(context: NSManagedObjectContext) -> [CalendarEvent] {
        let scheduleInfo = GetScheduleSectionInfo()
        let calendar = Calendar.current
        var (allCourseValid, success) = GetValidCourse(context: context)
        if !success || allCourseValid.count == 0 {
            return []
        }
        var semesterStartDate = allCourseValid.first!.SemesterStartDate
        var ret: [CalendarEvent] = []
        for course in allCourseValid {
            for (index, character) in course.ExistWeek.enumerated() {
                if character == "1" {
                    var currentEvent: CalendarEvent = CalendarEvent()
                    guard let date_day_start = calendar.date(byAdding: .day, value: 7 * index + (course.DayOfWeek - 1), to: semesterStartDate) else {
                        continue
                    }
                    guard let section_start = scheduleInfo.first(where: { $0.sectionIndex == course.StartSectionId }) else {
                        continue
                    }
                    guard let section_end = scheduleInfo.first(where: { $0.sectionIndex == course.EndSectionId }) else {
                        continue
                    }
                    currentEvent.title = course.CourseName
                    currentEvent.location = "\(course.SchoolRegion)\(course.ClassroomLocation) \(course.TeacherName)"
                    currentEvent.StartDate = SetDate(toSet: date_day_start, value: section_start.GetStartDateCp())
                    currentEvent.EndDate = SetDate(toSet: date_day_start, value: section_end.GetEndDateCp())
                    currentEvent.note = "\(course.ClassroomLocationTimeDes)\n\(course.SchoolRegion)\(course.ClassroomLocation)\n\(course.TeacherName)"
                    ret.append(currentEvent)
                }
            }
        }
        return ret
    }
    
    func GetAllCourseById(context: NSManagedObjectContext, courseId: String) -> [ScheduleCourseStored] {
        let request: NSFetchRequest<ScheduleCourseStored> = ScheduleCourseStored.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "courseId == %@", courseId))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        do {
            // 执行查询
            let results = try context.fetch(request)
            
            return results
        } catch {
            return []
        }
    }
    
    func DeleteScheduleCourse(context: NSManagedObjectContext, courseId: String, deleteOnlySpecDay: Int?) {
        // 如果deleteOnlySpecDay指定，则只删除dayOfWeek满足这一天deleteOnlySpecDay的且课程号courseId为参数courseId的，否则删除所有courseId符合的
        let request: NSFetchRequest<ScheduleCourseStored> = ScheduleCourseStored.fetchRequest()
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "courseId == %@", courseId))
        if let day = deleteOnlySpecDay {
            predicates.append(NSPredicate(format: "dayOfWeek == %d", day))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        do {
            // 执行查询
            let results = try context.fetch(request)
            
            // 删除符合条件的对象
            for course in results {
                context.delete(course)
            }
            
            // 保存更改
            try context.save()
        } catch {
            // 处理错误
            print("删除失败: \(error)")
        }
    }
}


