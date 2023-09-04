//
//  GlobalVariables.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation
import SwiftUI

class GlobalVariables {
    static let shared = GlobalVariables()
    @Published var isLogin = true
    @Published var courseList: [CourseShortInfo] = [
        CourseShortInfo(id: 11201, shortname: "数据结构与C++程序设计", progress: 66, coursecategory: "自动化学院"),
        CourseShortInfo(id: 11202, shortname: "数值分析", progress: 20, coursecategory: "数学学院")
    ]
    
    var debugMode = true

    private init() {
        
    }
}
