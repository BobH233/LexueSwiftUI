//
//  ContactMessage.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import Foundation

enum MessageBodyType: Codable {
    case text
    case image
    case link
}

struct MessageBodyItem: Codable {
    var type: MessageBodyType
    var image_data: String?
    var text_data: String?
    var link: String?
}

struct ContactMessage: Codable, Identifiable {
    var id = UUID()
    var sendDate: Int
    var senderUid: String?
    var messageBody: [MessageBodyItem]
}
