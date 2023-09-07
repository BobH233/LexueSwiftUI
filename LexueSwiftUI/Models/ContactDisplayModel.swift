//
//  ContactDisplayModel.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/7.
//

import Foundation

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
}
