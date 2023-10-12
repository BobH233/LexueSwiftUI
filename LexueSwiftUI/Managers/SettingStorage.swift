//
//  SettingStorage.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation

class SettingStorage: ObservableObject {
    static let shared = SettingStorage()
    
    // 是否同意应用隐私政策
    @Published var agreePrivacyPolicy: Bool {
        didSet {
            print("set setting.agreePrivacyPolicy \(agreePrivacyPolicy)")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(agreePrivacyPolicy, forKey: "setting.agreePrivacyPolicy")
        }
    }
    
    // 是否已经展示过推荐使用小组件的提示框了
    @Published var welcomWidgetShown: Bool {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(welcomWidgetShown, forKey: "setting.welcomWidgetShown")
        }
    }
    
    
    // 应用颜色选项
    @Published var preferColorScheme: Int {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(preferColorScheme, forKey: "setting.preferColorScheme")
        }
    }
    
    // 保存的账号密码
    @Published var savedUsername: String {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(savedUsername, forKey: "setting.login.username")
        }
    }
    
    @Published var savedPassword: String {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(savedPassword, forKey: "setting.login.password")
        }
    }
    
    // 保存的BIT登录信息
    @Published var loginnedContext: BITLogin.LoginSuccessContext {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(loginnedContext.happyVoyagePersonal, forKey: "setting.login.context.happyVoyage")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(loginnedContext.CASTGC, forKey: "setting.login.context.castgc")
        }
    }
    
    // 缓存的用户信息，用于下次应用打开的懒加载
    @Published var cacheUserInfo: LexueAPI.SelfUserInfo {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.userId, forKey: "setting.cacheUserInfo.userId")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.fullName, forKey: "setting.cacheUserInfo.fullName")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.firstAccessTime, forKey: "setting.cacheUserInfo.firstAccessTime")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.onlineUsers, forKey: "setting.cacheUserInfo.onlineUsers")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.email, forKey: "setting.cacheUserInfo.email")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.stuId, forKey: "setting.cacheUserInfo.stuId")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheUserInfo.phone, forKey: "setting.cacheUserInfo.phone")
        }
    }
    
    // 缓存的用户自己的lexue profile信息，用于判断是否是开发者权限、用户头像等等等等
    @Published var cacheSelfLexueProfile: LexueProfile {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheSelfLexueProfile.appVersion, forKey: "setting.cacheSelfLexueProfile.appVersion")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheSelfLexueProfile.avatarBase64, forKey: "setting.cacheSelfLexueProfile.avatarBase64")
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cacheSelfLexueProfile.isDeveloperMode, forKey: "setting.cacheSelfLexueProfile.isDeveloperMode")
        }
    }
    
    // 存储事件设置：凌晨跨越
    @Published var event_midnightFixTime: Int {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(event_midnightFixTime, forKey: "setting.events.event_midnightFixTime")
        }
    }
    
    // 存储事件设置：开启通知
    @Published var event_enableNotification: Bool {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(event_enableNotification, forKey: "setting.events.event_enableNotification")
        }
    }
    
    // 存储事件设置：提前提醒小时数
    @Published var event_preHour: Int {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(event_preHour, forKey: "setting.events.event_preHour")
        }
    }
    
    // 存储事件设置：提前提醒分钟数
    @Published var event_preMinute: Int {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(event_preMinute, forKey: "setting.events.event_preMinute")
        }
    }
    
    // 存储事件设置：是否只显示今天事件
    @Published var event_showTodayOnly: Bool {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(event_showTodayOnly, forKey: "setting.events.event_showTodayOnly")
        }
    }
    
    // 存储事件设置：当有新事件时是否提醒
    @Published var event_newEventNotification: Bool {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(event_newEventNotification, forKey: "setting.events.event_newEventNotification")
        }
    }
    
    // 缓存webvpn的cookie
    @Published var cache_webvpn_context: String {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cache_webvpn_context, forKey: "setting.cache_webvpn_context")
        }
    }
    
    // 缓存的cookie对应的用户名，防止不同登录缓存不刷新
    @Published var cache_webvpn_context_for_user: String {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(cache_webvpn_context_for_user, forKey: "setting.cache_webvpn_context_for_user")
        }
    }
    
    // 为了使小组件和app能够互通一些cookie之类的东西，因此把 sesskey 和 lexue_context 也存在这里
    // 对于app，在app从后台被重新唤醒的时候，需要从这里加载sesskey到GlobalVarible，当自己刷新sesskey成功的时候，需要写入到这里
    // 对于小组件，每次小组件gettimeline之前从这里加载到自己的GlobalVarible，当自己刷新sesskey成功的时候，也会写入到这里
    func set_widget_shared_sesskey(_ val: String) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(val, forKey: "shared.widget_shared_sesskey")
    }
    func get_widget_shared_sesskey() -> String {
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "shared.widget_shared_sesskey") as? String {
            return stored
        } else {
            return ""
        }
    }
    
    func set_widget_shared_LexueContext(_ val: LexueAPI.LexueContext) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(val.MoodleSession, forKey: "shared.widget_shared_LexueContext")
        
    }
    func get_widget_shared_LexueContext() -> LexueAPI.LexueContext {
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "shared.widget_shared_LexueContext") as? String {
            var ret = LexueAPI.LexueContext()
            ret.MoodleSession = stored
            return ret
        } else {
            return LexueAPI.LexueContext()
        }
    }
    
    func set_widget_shared_AppActiveDate(_ val: TimeInterval) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(val, forKey: "shared.widget_shared_AppActiveDate")
    }
    
    func get_widget_shared_AppActiveDate() -> TimeInterval {
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "shared.widget_shared_AppActiveDate") as? TimeInterval {
            return stored
        } else {
            return Date.now.timeIntervalSince1970
        }
    }
    
    
    private init() {
        
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.preferColorScheme") as? Int {
            preferColorScheme = stored
        } else {
            preferColorScheme = 2
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.login.username") as? String {
            savedUsername = stored
        } else {
            savedUsername = ""
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.login.password") as? String {
            savedPassword = stored
        } else {
            savedPassword = ""
        }
        if let stored1 = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.login.context.happyVoyage") as? String, let stored2 = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.login.context.castgc") as? String {
            loginnedContext = BITLogin.LoginSuccessContext(happyVoyagePersonal: stored1, CASTGC: stored2)
        } else {
            loginnedContext = BITLogin.LoginSuccessContext()
        }
        if let stored1 = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.userId") as? String {
            var tmpInfo = LexueAPI.SelfUserInfo()
            tmpInfo.userId = stored1
            tmpInfo.fullName = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.fullName") as? String ?? ""
            tmpInfo.firstAccessTime = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.firstAccessTime") as? String ?? ""
            tmpInfo.onlineUsers = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.onlineUsers") as? String ?? ""
            tmpInfo.email = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.email") as? String ?? ""
            tmpInfo.stuId = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.stuId") as? String ?? ""
            tmpInfo.phone = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheUserInfo.phone") as? String ?? ""
            cacheUserInfo = tmpInfo
        } else {
            cacheUserInfo = LexueAPI.SelfUserInfo()
        }
        
        if let stored1 = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheSelfLexueProfile.appVersion") as? String {
            var tmpProfile = LexueProfile()
            tmpProfile.appVersion = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheSelfLexueProfile.appVersion") as? String ?? ""
            tmpProfile.avatarBase64 = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheSelfLexueProfile.avatarBase64") as? String ?? ""
            tmpProfile.isDeveloperMode = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cacheSelfLexueProfile.isDeveloperMode") as? Bool ?? false
            cacheSelfLexueProfile = tmpProfile
        } else {
            cacheSelfLexueProfile = LexueProfile()
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.agreePrivacyPolicy") as? Bool {
            agreePrivacyPolicy = stored
        } else {
            agreePrivacyPolicy = false
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.events.event_midnightFixTime") as? Int {
            event_midnightFixTime = stored
        } else {
            event_midnightFixTime = 6
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.events.event_enableNotification") as? Bool {
            event_enableNotification = stored
        } else {
            event_enableNotification = true
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.events.event_preHour") as? Int {
            event_preHour = stored
        } else {
            event_preHour = 6
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.events.event_preMinute") as? Int {
            event_preMinute = stored
        } else {
            event_preMinute = 0
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.events.event_showTodayOnly") as? Bool {
            event_showTodayOnly = stored
        } else {
            event_showTodayOnly = false
        }
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.events.event_newEventNotification") as? Bool {
            event_newEventNotification = stored
        } else {
            event_newEventNotification = true
        }
        
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.welcomWidgetShown") as? Bool {
            welcomWidgetShown = stored
        } else {
            welcomWidgetShown = false
        }
        
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cache_webvpn_context") as? String {
            cache_webvpn_context = stored
        } else {
            cache_webvpn_context = ""
        }
        
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "setting.cache_webvpn_context_for_user") as? String {
            cache_webvpn_context_for_user = stored
        } else {
            cache_webvpn_context_for_user = ""
        }
        
    }
}
