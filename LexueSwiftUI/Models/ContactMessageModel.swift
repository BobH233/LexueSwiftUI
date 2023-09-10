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
}

struct MessageBodyItem: Codable, Equatable {
    var type: MessageBodyType
    var image_data: String?
    var text_data: String?
    var link: String?
    var link_title: String?
    var time_text: String?
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
