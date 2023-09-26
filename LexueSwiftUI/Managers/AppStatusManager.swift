//
//  AppStatusManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/13.
//

import Foundation
import SwiftUI

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
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法刷新乐学会话(sessKey)(get_context)"
                    GlobalVariables.shared.alertContent = "数据获取可能异常，建议重启应用再试。"
                    GlobalVariables.shared.showAlert = true
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
        print("\(#function)")
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
            self.OnAppTickToGetLexueContext()
        }
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
    
    // App切换到后台的时候
    func OnAppGoToBackground() {
        print("\(#function)")
        lastBackgroundTime = Int(Date().timeIntervalSince1970)
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
            }
        }
    }
    
    
    func OnAppTickToGetLexueContext() {
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
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法刷新乐学会话(sessKey)(Tick)"
                    GlobalVariables.shared.alertContent = "数据获取可能异常，建议重启应用再试。"
                    GlobalVariables.shared.showAlert = true
                }
            }
        }
    }
    
    // App从后台切换回前台的时候
    func OnAppGoToForeground() {
        print("\(#function)")
        if foregroundCnt == 0 {
            OnAppStart()
        } else {
            let deltaTime = Int(Date().timeIntervalSince1970) - lastBackgroundTime
            print("deltaTime: \(deltaTime)")
            if GlobalVariables.shared.isLogin && lastBackgroundTime != 0 && deltaTime > 1 {
                // 超过10分钟，需要刷新lexue的session
                print("BackGoreground 600s for get sessKey")
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
                        DispatchQueue.main.async {
                            GlobalVariables.shared.alertTitle = "无法刷新乐学会话(sessKey)(Background)"
                            GlobalVariables.shared.alertContent = "数据获取可能异常，建议重启应用再试。"
                            GlobalVariables.shared.showAlert = true
                        }
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
