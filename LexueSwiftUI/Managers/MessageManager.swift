//
//  MessageManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//  用于管理所有的联系人的消息
//

import Foundation
import CoreData


class MessageManager {
    static let shared = MessageManager()
    
    func GetSendDateDescriptionText(sendDate: Date) -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh-CN")
        if sendDate.isInSameDay(as: today) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if Calendar.current.isDateInYesterday(sendDate) {
            dateFormatter.dateFormat = "昨天 HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if sendDate.isInSameWeek(as: today) {
            dateFormatter.dateFormat = "EEEE HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if sendDate.isInSameYear(as: today) {
            dateFormatter.dateFormat = "MM-dd HH:mm"
            return dateFormatter.string(from: sendDate)
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter.string(from: sendDate)
        }
    }
    
    func InjectTimetagForMessages(messages: [ContactMessage]) -> [ContactMessage] {
        var ret: [ContactMessage] = []
        for (index, message) in messages.enumerated() {
            if index == 0 {
                ret.append(ContactMessage(time_text: GetSendDateDescriptionText(sendDate: message.sendDate)))
                ret.append(message)
            } else {
                var dateBefore: Date, dateAfter: Date
                if messages[index - 1].sendDate < message.sendDate {
                    dateBefore = messages[index - 1].sendDate
                    dateAfter = message.sendDate
                } else {
                    dateBefore = message.sendDate
                    dateAfter = messages[index - 1].sendDate
                }
                let components = Calendar.current.dateComponents([.minute], from: dateBefore, to: dateAfter)
                if let minutes = components.minute, minutes >= 30 {
                    // 这两个日期相差半个小时以上
                    ret.append(ContactMessage(time_text: GetSendDateDescriptionText(sendDate: message.sendDate)))
                    ret.append(message)
                } else {
                    // 这两个日期相差不到半个小时
                    ret.append(message)
                }
            }
        }
        return ret
    }
    
    func PushMessage(senderUid: String, type: MessageBodyType, text_data: String?, image_data: String?,
                          link_data: String?, link_title: String?, date: Date?, context: NSManagedObjectContext) {
        DataController.shared.addMessageStored(senderUid: senderUid, type: type, text_data: text_data, image_data: image_data, link_data: link_data, link_title: link_title, date: date, context: context)
        if let contact = DataController.shared.findContactStored(contactUid: senderUid, context: context) {
            contact.lastMessageDate = date ?? Date()
            contact.unreadCount = contact.unreadCount + 1
            DataController.shared.save(context: context)
        }
    }
    
    func GetMessageTextDescription(message: ContactMessage?) -> String {
        if let message = message {
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
        } else {
            return ""
        }
    }
    
    
}
