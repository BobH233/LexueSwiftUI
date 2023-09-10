//
//  ContactDisplayModel.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/7.
//

import Foundation

enum ContactType: Int, Codable {
    // 默认情况，没指定，不做特殊处理
    case not_spec = 0
    
    // 乐学的其他用户，主要考虑相互留言问题
    case lexue_user = 1
    
    // 乐学的课程抽象的一个联系人
    case course = 2
    
    // 消息提供者，主要用于后续接入 内置/第三方 消息推送源
    case msg_provider = 3
}

let ContactTypeString = [
    "未指定",
    "乐学用户",
    "乐学课程",
    "消息源"
]

struct ContactDisplayModel: Codable, Identifiable, Equatable  {
    init() {
        id = ""
        lastMessageDate = Date()
        contactUid = ""
        displayName = ""
        recentMessage = ""
        timeString = ""
        unreadCount = 0
        avatar_data = ""
        pinned = false
        silent = false
        type = 0
    }
    var id: String
    var lastMessageDate: Date
    var contactUid: String
    var displayName: String
    var recentMessage: String
    var timeString: String
    var unreadCount: Int
    var avatar_data: String
    var pinned: Bool
    var silent: Bool
    var type: Int
}
