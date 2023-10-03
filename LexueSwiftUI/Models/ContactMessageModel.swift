//
//  ContactMessage.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import Foundation

enum MessageBodyType: Int, Codable {
    case text = 0
    case image = 1
    case link = 2
    
    // 只在 MessageDetailView 页面显示这个时间
    case time = 3
    
    // 留给未来拓展富文本消息用的，目前暂时不使用
    case event_notification = 4
    case unknow2 = 5
    case unknow3 = 6
    case unknow4 = 7
    case unknow5 = 8
    case unknow6 = 9
    case unknow7 = 10
    case unknow8 = 11
    case unknow9 = 12
    case unknow10 = 13
    case unknow11 = 14
    case unknow12 = 15
    case unknow13 = 16
    case unknow14 = 17
}

struct MessageBodyItem: Codable, Equatable {
    var type: MessageBodyType
    var image_data: String?
    var text_data: String?
    var link: String?
    var link_title: String?
    var time_text: String?
    var event_name: String?
    var event_uuid: UUID?
    var event_starttime: String?
}

struct ContactMessage: Codable, Identifiable, Equatable {
    init() {
        id = UUID()
        sendDate = Date()
        senderUid = nil
        messageBody = MessageBodyItem(type: .text, image_data: nil, text_data: nil, link: nil, link_title: nil, time_text: nil)
    }
    init(time_text: String) {
        id = UUID()
        sendDate = Date()
        senderUid = nil
        messageBody = MessageBodyItem(type: .time, image_data: nil, text_data: nil, link: nil, link_title: nil, time_text: time_text)
    }
    var id = UUID()
    var sendDate: Date
    var senderUid: String?
    var messageBody: MessageBodyItem
}

struct ContactMessageSearchResult: Codable, Identifiable, Equatable {
    init() {
        id = UUID()
        messageUUID = UUID()
        sendTimeStr = ""
        contactUid = ""
        contactName = ""
        messageStart = ""
        messageSearched = ""
        messageEnd = ""
    }
    var id = UUID()
    var sendTimeStr: String
    var contactName: String
    var contactUid: String
    var messageStart: String
    var messageUUID: UUID
    var messageSearched: String
    var messageEnd: String
}
