//
//  SettingStorage.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation

class SettingStorage: ObservableObject {
    static let shared = SettingStorage()
    
    // 应用颜色选项
    @Published var preferColorScheme: Int {
        didSet {
            UserDefaults.standard.set(preferColorScheme, forKey: "setting.preferColorScheme")
        }
    }
    
    // 保存的账号密码
    @Published var savedUsername: String {
        didSet {
            UserDefaults.standard.set(savedUsername, forKey: "setting.login.username")
        }
    }
    
    @Published var savedPassword: String {
        didSet {
            UserDefaults.standard.set(savedPassword, forKey: "setting.login.password")
        }
    }
    
    // 保存的BIT登录信息
    @Published var loginnedContext: BITLogin.LoginSuccessContext {
        didSet {
            UserDefaults.standard.set(loginnedContext.happyVoyagePersonal, forKey: "setting.login.context.happyVoyage")
            UserDefaults.standard.set(loginnedContext.CASTGC, forKey: "setting.login.context.castgc")
        }
    }
    
    // 缓存的用户信息，用于下次应用打开的懒加载
    @Published var cacheUserInfo: LexueAPI.SelfUserInfo {
        didSet {
            UserDefaults.standard.set(cacheUserInfo.userId, forKey: "setting.cacheUserInfo.userId")
            UserDefaults.standard.set(cacheUserInfo.fullName, forKey: "setting.cacheUserInfo.fullName")
            UserDefaults.standard.set(cacheUserInfo.firstAccessTime, forKey: "setting.cacheUserInfo.firstAccessTime")
            UserDefaults.standard.set(cacheUserInfo.onlineUsers, forKey: "setting.cacheUserInfo.onlineUsers")
            UserDefaults.standard.set(cacheUserInfo.email, forKey: "setting.cacheUserInfo.email")
            UserDefaults.standard.set(cacheUserInfo.stuId, forKey: "setting.cacheUserInfo.stuId")
            UserDefaults.standard.set(cacheUserInfo.phone, forKey: "setting.cacheUserInfo.phone")
        }
    }
    
    // 缓存的用户自己的lexue profile信息，用于判断是否是开发者权限、用户头像等等等等
    @Published var cacheSelfLexueProfile: LexueProfile {
        didSet {
            UserDefaults.standard.set(cacheSelfLexueProfile.appVersion, forKey: "setting.cacheSelfLexueProfile.appVersion")
            UserDefaults.standard.set(cacheSelfLexueProfile.avatarBase64, forKey: "setting.cacheSelfLexueProfile.avatarBase64")
            UserDefaults.standard.set(cacheSelfLexueProfile.isDeveloperMode, forKey: "setting.cacheSelfLexueProfile.isDeveloperMode")
        }
    }
    
    private init() {
        if let stored = UserDefaults.standard.value(forKey: "setting.preferColorScheme") as? Int {
            preferColorScheme = stored
        } else {
            preferColorScheme = 2
        }
        if let stored = UserDefaults.standard.value(forKey: "setting.login.username") as? String {
            savedUsername = stored
        } else {
            savedUsername = ""
        }
        if let stored = UserDefaults.standard.value(forKey: "setting.login.password") as? String {
            savedPassword = stored
        } else {
            savedPassword = ""
        }
        if let stored1 = UserDefaults.standard.value(forKey: "setting.login.context.happyVoyage") as? String, let stored2 = UserDefaults.standard.value(forKey: "setting.login.context.castgc") as? String {
            loginnedContext = BITLogin.LoginSuccessContext(happyVoyagePersonal: stored1, CASTGC: stored2)
        } else {
            loginnedContext = BITLogin.LoginSuccessContext()
        }
        if let stored1 = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.userId") as? String {
            var tmpInfo = LexueAPI.SelfUserInfo()
            tmpInfo.userId = stored1
            tmpInfo.fullName = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.fullName") as? String ?? ""
            tmpInfo.firstAccessTime = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.firstAccessTime") as? String ?? ""
            tmpInfo.onlineUsers = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.onlineUsers") as? String ?? ""
            tmpInfo.email = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.email") as? String ?? ""
            tmpInfo.stuId = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.stuId") as? String ?? ""
            tmpInfo.phone = UserDefaults.standard.value(forKey: "setting.cacheUserInfo.phone") as? String ?? ""
            cacheUserInfo = tmpInfo
        } else {
            cacheUserInfo = LexueAPI.SelfUserInfo()
        }
        
        if let stored1 = UserDefaults.standard.value(forKey: "setting.cacheSelfLexueProfile.appVersion") as? String {
            var tmpProfile = LexueProfile()
            tmpProfile.appVersion = UserDefaults.standard.value(forKey: "setting.cacheSelfLexueProfile.appVersion") as? String ?? ""
            tmpProfile.avatarBase64 = UserDefaults.standard.value(forKey: "setting.cacheSelfLexueProfile.avatarBase64") as? String ?? ""
            tmpProfile.isDeveloperMode = UserDefaults.standard.value(forKey: "setting.cacheSelfLexueProfile.isDeveloperMode") as? Bool ?? false
            cacheSelfLexueProfile = tmpProfile
        } else {
            cacheSelfLexueProfile = LexueProfile()
        }
    }
}
