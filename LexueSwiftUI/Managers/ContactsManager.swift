//
//  ContactsManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//
//
import Foundation
import CoreData

class ContactsManager: ObservableObject {
    static let shared = ContactsManager()
    @Published var ContactDisplayLists: [ContactDisplayModel] = []
    
    
    func PinContact(contactUid: String, isPin: Bool, context: NSManagedObjectContext) {
        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context)
        if let contact = contact {
            contact.pinned = isPin
            DataController.shared.save(context: context)
            GenerateContactDisplayLists(context: context)
        }
    }
    
    func ReadallContact(contactUid: String, context: NSManagedObjectContext) {
        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context)
        if let contact = contact {
            contact.unreadCount = 0
            DataController.shared.save(context: context)
            GenerateContactDisplayLists(context: context)
        }
    }
    
    func GenerateContactDisplayLists(context: NSManagedObjectContext) {
        var result: [ContactDisplayModel] = []
        var contacts = DataController.shared.getAllContacts(context: context)
        // 排序，置顶的在前面，最近消息近的在前面
        contacts.sort { (contact1, contact2) in
            if contact1.pinned == contact2.pinned {
                // 如果 pinned 相同，则比较 lastMessageDate
                if let date1 = contact1.lastMessageDate, let date2 = contact2.lastMessageDate {
                    return date1 > date2
                } else {
                    return false
                }
            } else {
                // 按照 pinned 排序
                return contact1.pinned && !contact2.pinned
            }
        }
        for contact in contacts {
            var cur: ContactDisplayModel = ContactDisplayModel()
            cur.id = contact.contactUid!
            cur.lastMessageDate = contact.lastMessageDate!
            cur.contactUid = contact.contactUid!
            cur.displayName = contact.originName!
            cur.avatar_data = contact.avatar_data ?? "default_avatar"
            let latestMsg = DataController.shared.queryLastMessageByContactUid(senderUid: contact.contactUid!, context: context)
            cur.recentMessage = MessageManager.shared.GetMessageTextDescription(message: latestMsg)
            cur.timeString = MessageManager.shared.GetSendDateDescriptionText(sendDate: contact.lastMessageDate!)
            cur.unreadCount = Int(contact.unreadCount)
            cur.pinned = contact.pinned
            cur.silent = contact.silent
            result.append(cur)
        }
        ContactDisplayLists = result
    }
}
