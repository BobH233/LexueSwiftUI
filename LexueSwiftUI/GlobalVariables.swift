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
    @Published var isLogin = false
    
    @Published var isLoading = false
    @Published var LoadingText = ""
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertContent = ""
    
    @Published var cur_lexue_context = LexueAPI.LexueContext()
    
    @Published var cur_user_info = LexueAPI.SelfUserInfo()
    
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
