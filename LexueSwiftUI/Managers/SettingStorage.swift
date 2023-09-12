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
    }
}
