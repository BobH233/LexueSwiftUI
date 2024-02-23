//
//  ScheduleManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/22.
//
//  课程表管理相关

import Foundation
import CoreData

struct ScheduleSectionInfo {
    var sectionIndex: Int = 0
    var sectionStartDate: Date = Date()
    var sectionStartDateStr: String = ""
    var sectionEndDate: Date = Date()
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
    static let shared = EventManager()
    
    
}


