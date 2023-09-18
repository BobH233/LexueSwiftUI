//
//  LexueProfile.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/18.
//
//  乐学助手利用乐学的profile接口实现的自己的头像上传等等功能的结构体

import Foundation

struct LexueProfile: Codable {
    init() {
        appVersion = GlobalVariables.shared.appVersion
        avatarBase64 = ""
        isDeveloperMode = false
    }
    
    // 使用的app版本
    // @Since 1.0.0
    var appVersion: String
    
    // 用户上传的头像的base64编码
    // @Since 1.0.0
    var avatarBase64: String
    
    
    // 该用户是否允许使用开发者模式
    // @Since 1.0.0
    var isDeveloperMode: Bool
}
