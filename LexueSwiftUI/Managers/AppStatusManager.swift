//
//  AppStatusManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/13.
//

import Foundation

class AppStatusManager {
    static let shared = AppStatusManager()
    
    // 如果是0证明是第一次启动，可以进行登录操作等
    var foregroundCnt = 0
    
    func auto_relogin() {
        GlobalVariables.shared.LoadingText = "登录中"
        GlobalVariables.shared.isLoading = true
        var failedOperation = {
            GlobalVariables.shared.alertTitle = "自动登录失败"
            GlobalVariables.shared.alertContent = "请尝试重新登录你的账号，或者检查网络设置"
            GlobalVariables.shared.isLoading = false
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
                                GlobalVariables.shared.isLoading = false
                                GlobalVariables.shared.isLogin = true
                                GlobalVariables.shared.cur_lexue_context = context
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
        GlobalVariables.shared.LoadingText = "加载中"
        GlobalVariables.shared.isLoading = true
        // 首先检查全局是否保存了login界面的cookie，如果没有就尝试检查是否有记住密码
        if SettingStorage.shared.loginnedContext.CASTGC != "" {
            LexueAPI.shared.GetLexueContext(SettingStorage.shared.loginnedContext) { result in
                switch result {
                case .success(let context):
                    GlobalVariables.shared.isLoading = false
                    GlobalVariables.shared.isLogin = true
                    GlobalVariables.shared.cur_lexue_context = context
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
    }
    
    // App从后台切换回前台的时候
    func OnAppGoToForeground() {
        print("\(#function)")
        if foregroundCnt == 0 {
            OnAppStart()
        }
        foregroundCnt = foregroundCnt + 1
    }
    
    // App即将进入墓碑的时候
    func OnAppInactive() {
        print("\(#function)")
    }
    
}
