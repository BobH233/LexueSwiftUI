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
    
    private func wrapperContactMessage(origin: MessageStored) -> ContactMessage {
        var ret: ContactMessage = ContactMessage()
        ret.id = origin.id!
        ret.sendDate = origin.date!
        ret.senderUid = origin.senderUid
        ret.messageBody.type = MessageBodyType(rawValue: Int(origin.type))!
        ret.messageBody.image_data = origin.image_data
        ret.messageBody.link_title = origin.link_title
        ret.messageBody.link = origin.link_data
        ret.messageBody.text_data = origin.text_data
        return ret
    }
    
    func queryMessagesByContactUid(senderUid: String,  context: NSManagedObjectContext) -> [ContactMessage] {
        let request: NSFetchRequest<MessageStored> = MessageStored.fetchRequest()
        var ret: [ContactMessage] = [ContactMessage]()
        request.predicate = NSPredicate(format: "senderUid == %@", senderUid)
        do {
            let results = try context.fetch(request)
            for result in results {
                let cur: ContactMessage = wrapperContactMessage(origin: result)
                ret.append(cur)
            }
        } catch {
            print("查询联系人消息失败：\(error)")
        }
        return ret
    }
    
    func queryCourseCacheStoredById(id: String, context: NSManagedObjectContext) -> CourseShortInfo? {
        let request: NSFetchRequest<CourseCacheStored> = CourseCacheStored.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results[0].ToCourseShortInfo()
            } else {
                return nil
            }
        } catch {
            print("查询课程\(id) 失败")
            return nil
        }
    }
    
    func addCourseChacheStored(course: CourseShortInfo, context: NSManagedObjectContext) {
        var newStored = CourseCacheStored(context: context)
        newStored.id = course.id
        newStored.fullname = course.fullname
        newStored.shortname = course.shortname
        newStored.idnumber = course.idnumber
        newStored.summary = course.summary
        newStored.summaryformat = Int32(course.summaryformat ?? 0)
        newStored.startdate = Int64(course.startdate ?? 0)
        newStored.enddate = Int64(course.enddate ?? 0)
        newStored.visible = course.visible ?? true
        newStored.showactivitydates = course.showactivitydates ?? false
        newStored.showcompletionconditions = course.showcompletionconditions ?? false
        newStored.fullnamedisplay = course.fullnamedisplay
        newStored.viewurl = course.viewurl
        newStored.courseimage = course.courseimage
        newStored.progress = Int32(course.progress ?? 0)
        newStored.hasprogress = course.hasprogress ?? true
        newStored.isfavourite = course.isfavourite ?? false
        newStored.hidden = course.hidden ?? false
        newStored.showshortname = course.showshortname ?? false
        newStored.coursecategory = course.coursecategory
        newStored.local_favorite = course.local_favorite
        save(context: context)
    }
    
    func setCourseFavorite(courseId: String, isFavorite: Bool, context: NSManagedObjectContext) {
        let request: NSFetchRequest<CourseCacheStored> = CourseCacheStored.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", courseId)
        do {
            var recordsToUpdate = try context.fetch(request)
            for i in 0..<recordsToUpdate.count {
                recordsToUpdate[i].local_favorite = isFavorite
            }
            save(context: context)
            
        } catch {
            print("更新课程\(courseId) 失败")
        }
    }
    
    func updateCourseCacheStored(course: CourseShortInfo, context: NSManagedObjectContext) {
        let request: NSFetchRequest<CourseCacheStored> = CourseCacheStored.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", course.id)
        do {
            var recordsToUpdate = try context.fetch(request)
            for i in 0..<recordsToUpdate.count {
                recordsToUpdate[i].id = course.id
                recordsToUpdate[i].fullname = course.fullname
                recordsToUpdate[i].shortname = course.shortname
                recordsToUpdate[i].idnumber = course.idnumber
                recordsToUpdate[i].summary = course.summary
                recordsToUpdate[i].summaryformat = Int32(course.summaryformat ?? 0)
                recordsToUpdate[i].startdate = Int64(course.startdate ?? 0)
                recordsToUpdate[i].enddate = Int64(course.enddate ?? 0)
                recordsToUpdate[i].visible = course.visible ?? true
                recordsToUpdate[i].showactivitydates = course.showactivitydates ?? false
                recordsToUpdate[i].showcompletionconditions = course.showcompletionconditions ?? false
                recordsToUpdate[i].fullnamedisplay = course.fullnamedisplay
                recordsToUpdate[i].viewurl = course.viewurl
                recordsToUpdate[i].courseimage = course.courseimage
                recordsToUpdate[i].progress = Int32(course.progress ?? 0)
                recordsToUpdate[i].hasprogress = course.hasprogress ?? true
                recordsToUpdate[i].isfavourite = course.isfavourite ?? false
                recordsToUpdate[i].hidden = course.hidden ?? false
                recordsToUpdate[i].showshortname = course.showshortname ?? false
                recordsToUpdate[i].coursecategory = course.coursecategory
                // 唯独这个不要更新
                // recordsToUpdate[i].local_favorite = course.local_favorite
            }
            save(context: context)
        } catch {
            print("更新课程\(course.id ?? "null") 失败")
        }
    }
    
    func deleteCourseCacheStoredById(id: String, context: NSManagedObjectContext) {
        let request: NSFetchRequest<CourseCacheStored> = CourseCacheStored.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let recordsToDelete = try context.fetch(request)
            for record in recordsToDelete {
                context.delete(record)
            }
            save(context: context)
        } catch {
            print("删除课程\(id) 失败")
        }
    }
    
    func queryAllCourseCacheStored(context: NSManagedObjectContext) -> [CourseShortInfo] {
        let request: NSFetchRequest<CourseCacheStored> = CourseCacheStored.fetchRequest()
        var ret: [CourseShortInfo] = [CourseShortInfo]()
        do {
            let results = try context.fetch(request)
            for result in results {
                ret.append(result.ToCourseShortInfo())
            }
        } catch {
            print("查询课程列表失败：\(error)")
        }
        
        return ret
    }
    
    func blurSearchMessage(keyword: String, context: NSManagedObjectContext) -> [ContactMessage] {
        let request: NSFetchRequest<MessageStored> = MessageStored.fetchRequest()
        var ret: [ContactMessage] = [ContactMessage]()
        let predicate = NSPredicate(format: "link_title CONTAINS[cd] %@ OR text_data CONTAINS[cd] %@", keyword, keyword)
        request.predicate = predicate
        do {
            let results = try context.fetch(request)
            for result in results {
                let cur: ContactMessage = wrapperContactMessage(origin: result)
                ret.append(cur)
            }
        } catch {
            print("搜索联系人消息失败：\(error)")
        }
        return ret
    }
    
    func blurSearchContact(keyword: String, context: NSManagedObjectContext) -> [ContactStored] {
        let request: NSFetchRequest<ContactStored> = ContactStored.fetchRequest()
        var ret: [ContactStored] = [ContactStored]()
        let predicate = NSPredicate(format: "alias CONTAINS[cd] %@ OR originName CONTAINS[cd] %@ OR contactUid CONTAINS[cd] %@", keyword, keyword, keyword)
        request.predicate = predicate
        do {
            let results = try context.fetch(request)
            ret = results
        } catch {
            print("搜索联系人失败：\(error)")
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
    
    func addContactStored(contactUid: String, originName: String, pinned: Bool?, silent: Bool?, unreadCount: Int32?, avatar_data: String?, type: ContactType = .not_spec, context: NSManagedObjectContext) {
        let contactStored = ContactStored(context: context)
        contactStored.id = UUID()
        contactStored.type = Int32(type.rawValue)
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
    
    func addEventStored(context: NSManagedObjectContext) {
        let eventStored = EventStored(context: context)
    }
    
}


extension ContactStored {
    func GetDisplayName() -> String {
        if alias == nil || alias == "" {
            return originName ?? ""
        } else {
            return alias!
        }
    }
}

extension CourseCacheStored {
    func ToCourseShortInfo() -> CourseShortInfo {
        var ret: CourseShortInfo = CourseShortInfo()
        ret.id = id ?? ""
        ret.fullname = fullname
        ret.shortname = shortname
        ret.idnumber = idnumber
        ret.summary = summary
        ret.summaryformat = Int(summaryformat)
        ret.startdate = Int(startdate)
        ret.enddate = Int(enddate)
        ret.visible = visible
        ret.showactivitydates = showactivitydates
        ret.showcompletionconditions = showcompletionconditions
        ret.fullnamedisplay = fullnamedisplay
        ret.viewurl = viewurl
        ret.courseimage = courseimage
        ret.progress = Int(progress)
        ret.hasprogress = hasprogress
        ret.isfavourite = isfavourite
        ret.hidden = hidden
        ret.showshortname = showshortname
        ret.coursecategory = coursecategory
        ret.local_favorite = local_favorite
        return ret
    }
}
