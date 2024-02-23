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
}


