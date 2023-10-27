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
    
    // For debug
    func PushMessage(senderUid: String, type: MessageBodyType, text_data: String?, image_data: String?,
                          link_data: String?, link_title: String?, date: Date?, context: NSManagedObjectContext) {
        DataController.shared.addMessageStored(senderUid: senderUid, type: type, text_data: text_data, image_data: image_data, link_data: link_data, link_title: link_title, date: date, event_name: nil, event_starttime: nil, event_uuid: nil, context: context)
        if let contact = DataController.shared.findContactStored(contactUid: senderUid, context: context) {
            contact.lastMessageDate = date ?? Date()
            contact.unreadCount = contact.unreadCount + 1
            DataController.shared.save(context: context)
        }
    }
    
    // 推送一个消息给消息列表，如果联系人不存在则创建新联系人，存在则不创建新联系人
    func PushMessageWithContactCreation(senderUid: String, contactOriginNameIfMissing: String, contactTypeIfMissing: ContactType, msgBody: MessageBodyItem, date: Date?, notify: Bool = false, messageHash: String? = nil, context: NSManagedObjectContext) {
        let msg = DataController.shared.addMessageStoredFromMsgBody(senderUid: senderUid, msgBody: msgBody, date: date, msgHash: messageHash, context: context)
        if let contact = DataController.shared.findContactStored(contactUid: senderUid, context: context) {
            contact.lastMessageDate = date ?? Date()
            contact.unreadCount = contact.unreadCount + 1
            DataController.shared.save(context: context)
        } else {
            // 不存在联系人，创建
            DataController.shared.addContactStored(contactUid: senderUid, originName: contactOriginNameIfMissing, pinned: false, silent: false, unreadCount: 0, avatar_data: "", type: contactTypeIfMissing, context: context)
            let contact = DataController.shared.findContactStored(contactUid: senderUid, context: context)!
            contact.lastMessageDate = date ?? Date()
            contact.unreadCount = contact.unreadCount + 1
            DataController.shared.save(context: context)
        }
        if let contact = DataController.shared.findContactStored(contactUid: senderUid, context: context), notify {
            if !contact.silent {
                LocalNotificationManager.shared.PushNotification(title: contact.GetDisplayName(), body: GetMessageTextDecsription(messageBody: msgBody), userInfo: ["cmd": "contactMessage", "contactUid": contact.contactUid!, "msgId": msg.id!.uuidString], interval: 0.1)
            }
        }
        // 因为已经有数据库上的监控了，检测到数据库更新会自动同步的
        // GlobalVariables.shared.refreshUnreadMsgCallback?()
    }
    
    func GetMessageTextDecsription(messageBody: MessageBodyItem?) -> String {
        if let messagebody = messageBody {
            switch(messagebody.type) {
            case .text:
                return messagebody.text_data ?? ""
            case .link:
                return "[链接] \(messagebody.link_title!)"
            case .image:
                return "[图片]"
            case .new_event_notification:
                return "[新事件提醒] \(messagebody.event_name ?? "")"
            case .due_event_notification:
                return "[事件到期提醒] \(messagebody.event_name ?? "")"
            default:
                return "[未知消息]"
            }
        } else {
            return ""
        }
    }
    
    func GetMessageTextDescription(message: ContactMessage?) -> String {
        if let message = message {
            return GetMessageTextDecsription(messageBody: message.messageBody)
        } else {
            return ""
        }
    }
    
    
}
