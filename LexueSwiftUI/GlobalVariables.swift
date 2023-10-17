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
    
    // 如果是true，则表示为本机调试，使用友盟的develop的key，同时显示debug build的标志，否则为发布版本，使用友盟的release的key
    // TODO: release 时改成 false!!!!!
    let DEBUG_BUILD = true
    // TODO: 上架app store的时候改为app store
    let CURRENT_CHANNEL = "app_store"
    // TODO: 上架app store的时候改成false!!! 分发Test flight的时候裁成true!!!
    let TEST_FLIGHT_BUILD = false
    
    
    var appVersion = "1.0"
    
    @Published var isLogin = false
    
    @Published var isShowPrivacyPolicySheet = false
    
    @Published var isShowWelcomUseWidgetSheet = false
    
    @Published var isLoading = false
    @Published var LoadingText = ""
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertContent = ""
    
    @Published var cur_lexue_context = LexueAPI.LexueContext()
    
    @Published var cur_user_info = LexueAPI.SelfUserInfo()
    
    @Published var cur_lexue_sessKey = ""
    
    @Published var courseList: [CourseShortInfo] = []
    
    @Published var userAvatarUIImage: UIImage?
    
    @Published var defaultUIImage: UIImage?
    
    // 用于消息推送用
    @Published var deviceToken: String? = nil
    
    // 是否允许app进行跟踪
    @Published var enableTracking: Bool = false
    
    var handleNotificationMsg: (([AnyHashable : Any]) -> Void)?
    var refreshUnreadMsgCallback: (() -> Void)?
    
    // 默认是false
    @Published var debugMode = false

    private init() {
        userAvatarUIImage = UIImage(named: "default_avatar")
        defaultUIImage = UIImage(named: "default_avatar")
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
            print("AppVersion: \(appVersion)")
        }
    }
}
