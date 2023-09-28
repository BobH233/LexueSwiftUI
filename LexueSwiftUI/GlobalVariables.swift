//
//  GlobalVariables.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation
import SwiftUI

class GlobalVariables: ObservableObject {
    static let shared = GlobalVariables()
    var appVersion = "1.0"
    
    @Published var isLogin = false
    
    @Published var isShowPrivacyPolicySheet = false
    
    @Published var isLoading = false
    @Published var LoadingText = ""
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertContent = ""
    
    @Published var cur_lexue_context = LexueAPI.LexueContext()
    
    @Published var cur_user_info = LexueAPI.SelfUserInfo()
    
    @Published var cur_lexue_sessKey = ""
    
    @Published var courseList: [CourseShortInfo] = []
    
    @Published var userAvatarUIImage: UIImage
    
    var debugMode = true

    private init() {
        userAvatarUIImage = UIImage(named: "default_avatar")!
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
            print("AppVersion: \(appVersion)")
        }
    }
}
