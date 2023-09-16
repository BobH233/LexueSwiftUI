//
//  CoreLogicManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/14.
//

import Foundation

// 负责处理app的一些核心逻辑，比如登录，刷新等
class CoreLogicManager {
    static let shared = CoreLogicManager()
    
    func UpdateCourseList() async {
        let curCourseList = await LexueAPI.shared.GetAllCourseList(GlobalVariables.shared.cur_lexue_context, sesskey: GlobalVariables.shared.cur_lexue_sessKey)
        switch curCourseList {
        case .success(let courseList):
            DispatchQueue.main.async {
                CourseManager.shared.DiffAndUpdateCacheCourses(courseList)
            }
        case .failure(_):
            DispatchQueue.main.async {
                GlobalVariables.shared.alertTitle = "刷新乐学课程列表失败"
                GlobalVariables.shared.alertContent = "请检查网络连接并尝试重启app"
                GlobalVariables.shared.showAlert = true
            }
        }
    }
    
    func refreshSelfUserInfo() async -> Bool {
        let result = await LexueAPI.shared.GetSelfUserInfo(GlobalVariables.shared.cur_lexue_context)
        switch result {
        case .success(let data):
            DispatchQueue.main.async {
                GlobalVariables.shared.cur_user_info = data
                SettingStorage.shared.cacheUserInfo = data
            }
            return true
        case .failure(_):
            DispatchQueue.main.async {
                GlobalVariables.shared.alertTitle = "获取个人信息失败"
                GlobalVariables.shared.alertContent = "请检查网络情况并重启应用重试!"
                GlobalVariables.shared.showAlert = true
            }
            return false
        }
    }
}
