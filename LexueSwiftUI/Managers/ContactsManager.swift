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
            contact.lastUpdateDate = Date()
            contact.pinned = isPin
            DataController.shared.save(context: context)
            GenerateContactDisplayLists(context: context)
        }
    }
    func SilentContact(contactUid: String, isSilent: Bool, context: NSManagedObjectContext) {
        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context)
        if let contact = contact {
            contact.lastUpdateDate = Date()
            contact.silent = isSilent
            DataController.shared.save(context: context)
            GenerateContactDisplayLists(context: context)
        }
    }
    func SetAlias(contactUid: String, alias: String, context: NSManagedObjectContext) {
        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context)
        if let contact = contact {
            contact.lastUpdateDate = Date()
            contact.alias = alias
            DataController.shared.save(context: context)
            GenerateContactDisplayLists(context: context)
        }
    }
    
    func DeleteAllMessagesAboutContact(contactUid: String, context: NSManagedObjectContext, refresh: Bool = true) {
        DataController.shared.deleteMessagesByContactUid(senderUid: contactUid, context: context)
        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context)
        if let contact = contact {
            context.delete(contact)
            DataController.shared.save(context: context)
        }
        if refresh {
            GenerateContactDisplayLists(context: context)
        }
    }
    
    func ReadallContact(contactUidArr: [String], context: NSManagedObjectContext) {
        for contactUid in contactUidArr {
            if let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context) {
                contact.lastUpdateDate = Date()
                contact.unreadCount = 0
            }
        }
        DataController.shared.save(context: context)
    }
    
    func ReadallContact(contactUid: String, context: NSManagedObjectContext, refresh: Bool = true) {
        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: context)
        if let contact = contact {
            contact.lastUpdateDate = Date()
            contact.unreadCount = 0
            DataController.shared.save(context: context)
            if refresh {
                GenerateContactDisplayLists(context: context)
            }
        }
    }
    
    
    func ReadallForAllContact(context: NSManagedObjectContext) {
        let contacts = DataController.shared.getAllContacts(context: context)
        for contact in contacts {
            contact.lastUpdateDate = Date()
            contact.unreadCount = 0
        }
        DataController.shared.save(context: context)
        GenerateContactDisplayLists(context: context)
    }
    
    var currentFilterOption = "全部"
    
    func GenerateContactDisplayLists(context: NSManagedObjectContext) {
        if currentFilterOption == "全部" {
            GenerateContactDisplayLists_internal(context: context)
        } else if currentFilterOption == "未读" {
            GenerateContactDisplayLists_internal(context: context, unreadOnly: true)
        } else if currentFilterOption == "置顶" {
            GenerateContactDisplayLists_internal(context: context, pinnedOnly: true)
        }
    }
    
    func GenerateContactDisplayLists_internal(context: NSManagedObjectContext, unreadOnly: Bool = false, pinnedOnly: Bool = false) {
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
        var uniqueContactUids = Set<String>()
        for contact in contacts {
            if uniqueContactUids.contains(contact.contactUid!) {
                continue
            }
            if unreadOnly && contact.unreadCount == 0 {
                continue
            }
            if pinnedOnly && !contact.pinned {
                continue
            }
            uniqueContactUids.insert(contact.contactUid!)
            var cur: ContactDisplayModel = ContactDisplayModel()
            cur.id = contact.contactUid!
            cur.lastMessageDate = contact.lastMessageDate!
            cur.contactUid = contact.contactUid!
            cur.displayName = contact.GetDisplayName()
            cur.avatar_data = contact.avatar_data ?? "default_avatar"
            let latestMsg = DataController.shared.queryLastMessageByContactUid(senderUid: contact.contactUid!, context: context)
            cur.recentMessage = MessageManager.shared.GetMessageTextDescription(message: latestMsg)
            cur.timeString = MessageManager.shared.GetSendDateDescriptionText(sendDate: contact.lastMessageDate!)
            cur.unreadCount = Int(contact.unreadCount)
            cur.pinned = contact.pinned
            cur.silent = contact.silent
            cur.scrollToMsgId = nil
            result.append(cur)
        }
        ContactDisplayLists = result
    }
}
