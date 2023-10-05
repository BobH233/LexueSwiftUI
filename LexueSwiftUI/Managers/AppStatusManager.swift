//
//  AppStatusManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/13.
//

import Foundation
import SwiftUI
import BackgroundTasks
import WidgetKit

class AppStatusManager {
    static let shared = AppStatusManager()
    
    // 如果是0证明是第一次启动，可以进行登录操作等
    var foregroundCnt = 0
    
    // 最后一次进入后台的时间
    var lastBackgroundTime: Int = 0
    
    
    
    func action_after_get_lexue_context(_ context: LexueAPI.LexueContext) {
        print("action_after_get_lexue_context")
        CourseManager.shared.LoadStoredCacheCourses()
        // 获取sesskey，更新课程列表
        Task {
            let result = await LexueAPI.shared.GetSessKey(context)
            switch result {
            case .success(let (sesskey, _)):
                DispatchQueue.main.async {
                    GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    Task {
                        await CoreLogicManager.shared.UpdateCourseList()
                    }
                    // 获取事件列表
                    Task {
                        try? await CoreLogicManager.shared.UpdateEventList()
                        await DataProviderManager.shared.DoRefreshAll()
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法刷新乐学会话(sessKey)(get_context)"
                    GlobalVariables.shared.alertContent = "数据获取可能异常，建议重启应用再试。"
                    GlobalVariables.shared.showAlert = true
                    UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "无法刷新乐学会话(sessKey)(get_context)"])
                }
            }
        }
        // 刷新用户的信息
        Task {
            DispatchQueue.main.async {
                // 优化体验，先默认用上一次存储的缓存用户信息，毕竟用户信息不会有太大变化
                GlobalVariables.shared.cur_user_info = SettingStorage.shared.cacheUserInfo
                GlobalVariables.shared.isLoading = false
                GlobalVariables.shared.isLogin = true
            }
            let ret = await CoreLogicManager.shared.RefreshSelfUserInfo()
            if !ret {
                DispatchQueue.main.async {
                    GlobalVariables.shared.isLogin = false
                }
            }
        }
        // 获取用户lexue profile的信息
        Task {
            let myProfile = await LexueAPI.shared.GetUserProfile(GlobalVariables.shared.cur_lexue_context, userId: SettingStorage.shared.cacheUserInfo.userId)
            switch myProfile {
            case .success(let profileHtml):
                // 处理获取到的信息
                let _ = await CoreLogicManager.shared.LoadSelfProfileOrUpdate(profileHtml)
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法获取个人信息(LexueProfile)"
                    GlobalVariables.shared.alertContent = "个人数据显示可能异常，建议重启应用再试。"
                    GlobalVariables.shared.showAlert = true
                    UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "无法获取个人信息(LexueProfile)"])
                }
            }
        }
    }
    
    func auto_relogin() {
        GlobalVariables.shared.LoadingText = "登录中"
        GlobalVariables.shared.isLoading = true
        let failedOperation = {
            GlobalVariables.shared.alertTitle = "自动登录失败"
            GlobalVariables.shared.alertContent = "请尝试重新登录你的账号，或者检查网络设置"
            GlobalVariables.shared.isLoading = false
            GlobalVariables.shared.isLogin = false
            SettingStorage.shared.loginnedContext.CASTGC = ""
            SettingStorage.shared.loginnedContext.happyVoyagePersonal = ""
            GlobalVariables.shared.showAlert = true
            UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "自动登录失败"])
        }
        BITLogin.shared.init_login_param() { result in
            switch result {
            case .failure(_):
                print("尝试自动登录失败1")
                failedOperation()
            case .success(let loginContext):
                BITLogin.shared.do_login(context: loginContext, username: SettingStorage.shared.savedUsername, password: SettingStorage.shared.savedPassword, captcha: "") { result in
                    GlobalVariables.shared.isLoading = false
                    switch result {
                    case .success(let data):
                        print(data)
                        SettingStorage.shared.loginnedContext = data
                        LexueAPI.shared.GetLexueContext(SettingStorage.shared.loginnedContext) { result in
                            switch result {
                            case .success(let context):
                                GlobalVariables.shared.cur_lexue_context = context
                                self.action_after_get_lexue_context(context)
                            case .failure(_):
                                // 直接清空，让用户重新登录
                                print("尝试自动登录失败3")
                                failedOperation()
                            }
                        }
                    case .failure(_):
                        // 直接清空，让用户重新登录
                        print("尝试自动登录失败2")
                        failedOperation()
                    }
                }
            }
        }
    }
    
    
    // App从没运行，到运行的时候
    func OnAppStart() {
        // 如果还没同意隐私政策，则必须先同意隐私政策
        if !SettingStorage.shared.agreePrivacyPolicy {
            GlobalVariables.shared.isShowPrivacyPolicySheet = true
            return
        }
        
        print("\(#function)")
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
            self.OnAppTickEveryMinute()
        }
        UMengManager.shared.AppStartLogic()
        LocalNotificationManager.shared.GuardNotificationPermission()
        GlobalVariables.shared.LoadingText = "加载中"
        GlobalVariables.shared.isLoading = true
        if let data = Data(base64Encoded: SettingStorage.shared.cacheSelfLexueProfile.avatarBase64 ?? ""), let image = UIImage(data: data) {
            GlobalVariables.shared.userAvatarUIImage = image
        }
        // 首先检查全局是否保存了login界面的cookie，如果没有就尝试检查是否有记住密码
        if SettingStorage.shared.loginnedContext.CASTGC != "" {
            LexueAPI.shared.GetLexueContext(SettingStorage.shared.loginnedContext) { result in
                switch result {
                case .success(let context):
                    GlobalVariables.shared.cur_lexue_context = context
                    self.action_after_get_lexue_context(context)
                case .failure(_):
                    // 后续处理逻辑，重新登录
                    print("try autologin failed")
                    self.auto_relogin()
                }
            }
        } else {
            GlobalVariables.shared.isLoading = false
        }
    }
    
    static func scheduleAppBackgroundRefresh() {
        print("scheduleAppBackgroundRefresh")
        let request = BGAppRefreshTaskRequest(identifier: "cn.bobh.LexueSwiftUI.BGRefresh")
        request.earliestBeginDate = .now.addingTimeInterval(30 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"cn.bobh.LexueSwiftUI.BGRefresh"]
            // print("okok!!")
        } catch {
            print("error: \(error.localizedDescription)")
        }
        
    }
    
    // App切换到后台的时候
    func OnAppGoToBackground() {
        print("\(#function)")
        lastBackgroundTime = Int(Date().timeIntervalSince1970)
        AppStatusManager.scheduleAppBackgroundRefresh()
        WidgetCenter.shared.reloadAllTimelines()
        print("recordTime: \(lastBackgroundTime)")
    }
    
    func RefreshLexueContext(silent_refresh: Bool) {
        GlobalVariables.shared.LoadingText = "刷新中"
        if !silent_refresh {
            GlobalVariables.shared.isLoading = true
        }
        LexueAPI.shared.GetLexueContext(SettingStorage.shared.loginnedContext) { result in
            switch result {
            case .success(let context):
                GlobalVariables.shared.isLoading = false
                GlobalVariables.shared.isLogin = true
                GlobalVariables.shared.cur_lexue_context = context
            case .failure(_):
                // 直接清空，让用户重新登录
                print("刷新lexue cookie 失败")
                GlobalVariables.shared.alertTitle = "刷新乐学会话失败"
                GlobalVariables.shared.alertContent = "请尝试重新登录你的账号，或者检查网络设置"
                GlobalVariables.shared.isLoading = false
                GlobalVariables.shared.isLogin = false
                SettingStorage.shared.loginnedContext.CASTGC = ""
                SettingStorage.shared.loginnedContext.happyVoyagePersonal = ""
                GlobalVariables.shared.showAlert = true
                UMAnalyticsSwift.event(eventId: "universal_error", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId, "error_type": "刷新乐学会话失败"])
            }
        }
    }
    
    
    func OnAppTickEveryMinute() {
        SettingStorage.shared.set_widget_shared_AppActiveDate(Date.now.timeIntervalSince1970)
        if !GlobalVariables.shared.isLogin {
            return
        }
        // 刷新sesskey
        Task {
            print("OnTick60s for get sesskey...")
            let result = await LexueAPI.shared.GetSessKey(GlobalVariables.shared.cur_lexue_context)
            switch result {
            case .success(let (sesskey, _)):
                DispatchQueue.main.async {
                    GlobalVariables.shared.cur_lexue_sessKey = sesskey
                }
            case .failure(_):
//                DispatchQueue.main.async {
//                    GlobalVariables.shared.alertTitle = "无法刷新乐学会话(sessKey)(Tick)"
//                    GlobalVariables.shared.alertContent = "数据获取可能异常，建议重启应用再试。"
//                    GlobalVariables.shared.showAlert = true
//                }
                // 不显示弹窗了，用户看见不舒服，直接记录下来，应该不会影响其他功能
                print("error: sesskey_fail_tick")
                UMAnalyticsSwift.event(eventId: "sesskey_fail_tick", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId])
                break
            }
        }
        // 刷新消息源以及事件列表
        Task(timeout: 50) {
            do {
                try? await CoreLogicManager.shared.UpdateEventList()
                print("Refreshing data providers...")
                await DataProviderManager.shared.DoRefreshAll()
            } catch {
                print("刷新消息超时!")
            }
        }
    }
    
    // App从后台切换回前台的时候
    func OnAppGoToForeground() {
        SettingStorage.shared.set_widget_shared_AppActiveDate(Date.now.timeIntervalSince1970)
        print("\(#function)")
        if foregroundCnt == 0 {
            OnAppStart()
        } else {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            let deltaTime = Int(Date().timeIntervalSince1970) - lastBackgroundTime
            print("deltaTime: \(deltaTime)")
            // 刷新这个sesskey，因为可能小组件已经动过了
            GlobalVariables.shared.cur_lexue_sessKey = SettingStorage.shared.get_widget_shared_sesskey()
            GlobalVariables.shared.cur_lexue_context = SettingStorage.shared.get_widget_shared_LexueContext()
            // print(GlobalVariables.shared.cur_lexue_context)
            // 从后台切回来才刷新事件
            Task {
                try? await CoreLogicManager.shared.UpdateEventList()
                await DataProviderManager.shared.DoRefreshAll()
            }
            if GlobalVariables.shared.isLogin && lastBackgroundTime != 0 && deltaTime > 60 {
                // 超过1分钟，需要刷新lexue的sesskey
                // 切回重新刷新sesskey的阈值时间设定为60s，因为如果没被踢刷新速度会很快，所以不必担心体验问题
                print("BackGoreground 60s for get sessKey")
                // RefreshLexueContext(silent_refresh: false)  // 不用这个方式了，因为GetSessKey自带重试处理，所以可以直接刷新SessKey
                GlobalVariables.shared.LoadingText = "刷新中"
                GlobalVariables.shared.isLoading = true
                Task {
                    let result = await LexueAPI.shared.GetSessKey(GlobalVariables.shared.cur_lexue_context)
                    DispatchQueue.main.async {
                        GlobalVariables.shared.isLoading = false
                    }
                    switch result {
                    case .success(let (sesskey, _)):
                        DispatchQueue.main.async {
                            GlobalVariables.shared.cur_lexue_sessKey = sesskey
                        }
                    case .failure(_):
//                        DispatchQueue.main.async {
//                            GlobalVariables.shared.alertTitle = "无法刷新乐学会话(sessKey)(Background)"
//                            GlobalVariables.shared.alertContent = "数据获取可能异常，建议重启应用再试。"
//                            GlobalVariables.shared.showAlert = true
//                        }
                        // 不显示弹窗了，用户看见不舒服，直接记录下来，应该不会影响其他功能
                        print("error: sesskey_fail_background")
                        UMAnalyticsSwift.event(eventId: "sesskey_fail_background", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId])
                        break
                    }
                }
            }
        }
        foregroundCnt = foregroundCnt + 1
    }
    
    // App即将进入墓碑的时候
    func OnAppInactive() {
        print("\(#function)")
    }
    
}
