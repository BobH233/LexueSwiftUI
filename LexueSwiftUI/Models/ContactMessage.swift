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
}

struct MessageBodyItem: Codable {
    var type: MessageBodyType
    var image_data: String?
    var text_data: String?
    var link: String?
    var link_title: String?
}

struct ContactMessage: Codable, Identifiable {
    var id = UUID()
    var sendDate: Date
    var senderUid: String?
    var messageBody: MessageBodyItem
}
