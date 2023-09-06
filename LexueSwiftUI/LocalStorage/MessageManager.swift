//
//  MessageManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//  用于管理所有的联系人的消息
//

import Foundation

class MessageManager {
    
    func GetContactMessages(contactId: String) -> [ContactMessage] {
        // TODO:
        return [ContactMessage]()
    }
    
    func GetMessageTextDescription(message: ContactMessage) -> String {
        switch(message.messageBody.type) {
        case .text:
            return message.messageBody.text_data ?? ""
        case .link:
            return "[链接] \(message.messageBody.link_title!)"
        case .image:
            return "[图片]"
        default:
            return "[未知消息]"
        }
    }
    
    
}
