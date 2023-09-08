//
//  GlobalVariables.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation
import SwiftUI

class GlobalVariables: ObservableObject {
    static let shared = GlobalVariables()
    @Published var isLogin = true
    @Published var courseList: [CourseShortInfo] = [
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: UUID().uuidString, shortname: UUID().uuidString, progress: 66, coursecategory: "自动化学院"),
        
    ]
    
    var debugMode = true

    private init() {
        
    }
}
