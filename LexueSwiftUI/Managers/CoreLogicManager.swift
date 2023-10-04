//
//  CoreLogicManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/14.
//

import Foundation
import SwiftSoup
import SwiftUI
import CoreData

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
                UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "刷新乐学课程列表失败"])
            }
        }
    }
    
    func UpdateEventList() async throws {
        var recent_events:[LexueAPI.EventInfo] = []
        for i in -3 ... 7 {
            let currentDate = Date()
            let target_date = Calendar.current.date(byAdding: .day, value: i, to: currentDate)
            let target_date_comp = Calendar.current.dateComponents([.year, .month, .day], from: target_date!)
            let tmpRes = try await LexueAPI.shared.GetEventsByDay(GlobalVariables.shared.cur_lexue_context, sesskey: GlobalVariables.shared.cur_lexue_sessKey, year: String(target_date_comp.year!), month: String(target_date_comp.month!), day: String(target_date_comp.day!))
            switch tmpRes {
            case .success(let events):
                recent_events.append(contentsOf: events)
            case .failure(_):
                print("fail to fetch \(target_date_comp)")
            }
        }
        await DataController.shared.container.performBackgroundTask { (context) in
            EventManager.shared.DiffAndUpdateCacheEvent(recent_events, context: context)
        }
    }
    
    func RefreshSelfUserInfo() async -> Bool {
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
                UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "获取个人信息失败"])
            }
            return false
        }
    }
    
    // newVal中为nil的不会改变，只有不为nil的才会得到更新
    func UpdateSelfProfile(_ newVal: LexueProfile) async {
        // 先设定为合适的值，再上传
        var toUpdate = SettingStorage.shared.cacheSelfLexueProfile
        if let appVersion = newVal.appVersion {
            toUpdate.appVersion = appVersion
            DispatchQueue.main.async {
                SettingStorage.shared.cacheSelfLexueProfile.appVersion = appVersion
            }
        }
        if let avatarBase64 = newVal.avatarBase64 {
            toUpdate.avatarBase64 = avatarBase64
            DispatchQueue.main.async {
                SettingStorage.shared.cacheSelfLexueProfile.avatarBase64 = avatarBase64
            }
        }
        if let isDeveloperMode = newVal.isDeveloperMode {
            toUpdate.isDeveloperMode = isDeveloperMode
            DispatchQueue.main.async {
                SettingStorage.shared.cacheSelfLexueProfile.isDeveloperMode = isDeveloperMode
            }
        }
        
        let profile1 = await LexueAPI.shared.GetEditProfileParam(GlobalVariables.shared.cur_lexue_context)
        switch profile1 {
        case .success(var editProfileParam):
            do {
                let jsonData = try toUpdate.toJSON()
                let jsonText = String(data: jsonData, encoding: .utf8)!
                // print(jsonText)
                editProfileParam.description_editor_text_ = "<div style=\"font-size:0px;\">\(jsonText)</div>"
                let updateRes = await LexueAPI.shared.UpdateProfile(GlobalVariables.shared.cur_lexue_context, newProfile: editProfileParam)
                switch updateRes {
                case .success(_):
                    break
                case .failure(_):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.alertTitle = "无法上传用户配置信息到乐学"
                        GlobalVariables.shared.alertContent = "头像设置功能等可能异常，请app退出重试"
                        GlobalVariables.shared.showAlert = true
                        UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "无法上传用户配置信息到乐学1"])
                    }
                }
            } catch {
                print(error)
            }
        case .failure(_):
            DispatchQueue.main.async {
                GlobalVariables.shared.alertTitle = "无法上传用户配置信息到乐学"
                GlobalVariables.shared.alertContent = "头像设置功能等可能异常，请app退出重试"
                GlobalVariables.shared.showAlert = true
                UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "无法上传用户配置信息到乐学2"])
            }
        }
    }
    
    // 加载自己的lexue profile（返回false），如果是第一次，还没有lexue profile，则会主动上传（返回true）
    func LoadSelfProfileOrUpdate(_ profileHtml: String) async -> Bool {
        // print("Loading profile html: \(profileHtml)")
        do {
            let document = try SwiftSoup.parse(profileHtml)
            let divsWithFontSizeZero = try document.select("div[style*=font-size:0px;]")
            if let div = divsWithFontSizeZero.first() {
                // 找到了，解析内部的内容
                let jsonContent = try div.text()
                do {
                    let tmpProfile = try LexueProfile.fromJSON(jsonContent)
                    DispatchQueue.main.async {
                        SettingStorage.shared.cacheSelfLexueProfile.avatarBase64 = tmpProfile.avatarBase64
                        SettingStorage.shared.cacheSelfLexueProfile.isDeveloperMode = tmpProfile.isDeveloperMode
                        GlobalVariables.shared.debugMode = tmpProfile.isDeveloperMode ?? false
                        if let data = Data(base64Encoded: tmpProfile.avatarBase64 ?? ""), let image = UIImage(data: data) {
                            GlobalVariables.shared.userAvatarUIImage = image
                        }
                    }
                    if tmpProfile.appVersion != GlobalVariables.shared.appVersion {
                        // 单独更新一下app的版本即可
                        print("update app version to profile!")
                        var toUpdate = LexueProfile.getNilObject()
                        toUpdate.appVersion = GlobalVariables.shared.appVersion
                        await UpdateSelfProfile(toUpdate)
                    }
                    return false
                } catch {
                    print("No lexue profile div found!")
                    await UpdateSelfProfile(LexueProfile())
                    return true
                }
            } else {
                // 没有找到符合条件的div标签
                print("No lexue profile div found!")
                await UpdateSelfProfile(LexueProfile())
                return true
            }
        } catch {
            print("No lexue profile div found!")
            await UpdateSelfProfile(LexueProfile())
            return true
        }
    }
}
