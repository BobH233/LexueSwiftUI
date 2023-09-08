//
//  DataController.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()
    let container = NSPersistentContainer(name: "MessageModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("fatal: Failed to load core data! \(error.localizedDescription)")
                exit(-1)
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func queryMessagesByContactUid(senderUid: String,  context: NSManagedObjectContext) -> [ContactMessage] {
        let request: NSFetchRequest<MessageStored> = MessageStored.fetchRequest()
        var ret: [ContactMessage] = [ContactMessage]()
        request.predicate = NSPredicate(format: "senderUid == %@", senderUid)
        do {
            let results = try context.fetch(request)
            for result in results {
                var cur: ContactMessage = ContactMessage()
                cur.id = result.id!
                cur.sendDate = result.date!
                cur.senderUid = result.senderUid
                cur.messageBody.type = MessageBodyType(rawValue: Int(result.type))!
                cur.messageBody.image_data = result.image_data
                cur.messageBody.link_title = result.link_title
                cur.messageBody.link = result.link_data
                cur.messageBody.text_data = result.text_data
                ret.append(cur)
            }
        } catch {
            print("查询联系人消息失败：\(error)")
        }
        return ret
    }
    
    func queryLastMessageByContactUid(senderUid: String,  context: NSManagedObjectContext) -> ContactMessage? {
        let messages = queryMessagesByContactUid(senderUid: senderUid, context: context)
        if messages.count == 0 {
            return nil
        } else {
            return messages.last
        }
    }
    
    func getAllContacts(context: NSManagedObjectContext) -> [ContactStored] {
        let request: NSFetchRequest<ContactStored> = ContactStored.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("查询联系人失败：\(error)")
        }
        return []
    }
    
    func addMessageStored(senderUid: String, type: MessageBodyType, text_data: String?, image_data: String?, 
                          link_data: String?, link_title: String?, date: Date?, context: NSManagedObjectContext) {
        let msgStored = MessageStored(context: context)
        msgStored.id = UUID()
        msgStored.senderUid = senderUid
        msgStored.type = Int32(type.rawValue)
        msgStored.text_data = text_data
        msgStored.image_data = image_data
        msgStored.link_data = link_data
        msgStored.link_title = link_title
        msgStored.date = date ?? Date()
        save(context: context)
    }
    
    func findContactStored(contactUid: String, context: NSManagedObjectContext) -> ContactStored? {
        let request: NSFetchRequest<ContactStored> = ContactStored.fetchRequest()
        request.predicate = NSPredicate(format: "contactUid == %@", contactUid)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch {
            print("查询联系人消息失败：\(error)")
        }
        return nil
    }
    
    func addContactStored(contactUid: String, originName: String, pinned: Bool?, silent: Bool?, unreadCount: Int32?, avatar_data: String?, context: NSManagedObjectContext) {
        let contactStored = ContactStored(context: context)
        contactStored.id = UUID()
        contactStored.contactUid = contactUid
        contactStored.lastMessageDate = Date()
        contactStored.originName = originName
        contactStored.avatar_data = avatar_data ?? "default_avatar"
        contactStored.pinned = pinned ?? false
        contactStored.silent = silent ?? false
        contactStored.unreadCount = unreadCount ?? 0
        contactStored.alias = nil
        save(context: context)
    }
    
}
