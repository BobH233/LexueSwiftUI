//
//  CourseManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import Foundation
import CoreData

class CourseManager: ObservableObject {
    static let shared = CourseManager()
    @Published var CourseDisplayList: [CourseShortInfo] = []
    
    // 从数据库加载上次缓存的课程列表
    func LoadStoredCacheCourses(context: NSManagedObjectContext = DataController.shared.container.viewContext) {
        var result = DataController.shared.queryAllCourseCacheStored(context: context)
        // 排序，加星的在前面，开始时间最晚的在最前面
        result.sort { (course1, course2) in
            if course1.local_favorite == course2.local_favorite {
                return course1.startdate! > course2.startdate!
            } else {
                // 按照 local_favorite 排序
                return course1.local_favorite && !course2.local_favorite
            }
        }
        CourseDisplayList = result
    }
    
    func FavoriteCourse(courseId: String, isFavorite: Bool, context: NSManagedObjectContext) {
        DataController.shared.setCourseFavorite(courseId: courseId, isFavorite: isFavorite, context: context)
        LoadStoredCacheCourses()
    }
    
    // 对比最新获取的列表的差异，然后更新数据库的内容
    func DiffAndUpdateCacheCourses(_ newCourseList: [CourseShortInfo]) {
        print("DiffAndUpdateCacheCourses")
        var lastSet = Set<String>()
        var curSet = Set<String>()
        for course in CourseDisplayList {
            lastSet.insert(course.id)
        }
        // 先看有无新增的课程
        for course in newCourseList {
            if !lastSet.contains(course.id) {
                // 新增
                // print("new \(course.id)")
                DataController.shared.addCourseChacheStored(course: course, context: DataController.shared.container.viewContext)
            } else {
                // 更新
                DataController.shared.updateCourseCacheStored(course: course, context: DataController.shared.container.viewContext)
            }
            curSet.insert(course.id)
        }
        // 再看有没有要删除的课程
        for course in CourseDisplayList {
            if !curSet.contains(course.id) {
                // 删除
                print("delete \(course.id)")
                DataController.shared.deleteCourseCacheStoredById(id: course.id, context: DataController.shared.container.viewContext)
            }
        }
        // 然后刷新CourseDisplayList
        LoadStoredCacheCourses()
    }
    
    
}
