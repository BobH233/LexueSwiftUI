//
//  DataController.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import Foundation
import CoreData
import SwiftUI
import CloudKit

class DataController: ObservableObject {
    static let shared = DataController()
    
    lazy var container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "MessageModel")
        let url = URL.storeURL(for: "group.cn.bobh.LexueSwiftUI", databaseName: "MessageModel")
        let cloudSyncDescriptor = NSPersistentStoreDescription(url: url)
        let localStoredDescriptor = NSPersistentStoreDescription(url: URL.storeURL(for: "group.cn.bobh.LexueSwiftUI", databaseName: "MessageModel_local"))
        
        cloudSyncDescriptor.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudSyncDescriptor.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        cloudSyncDescriptor.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.cn.bobh.LexueSwiftUI")
        cloudSyncDescriptor.configuration = "NeedSync"
        cloudSyncDescriptor.cloudKitContainerOptions?.databaseScope = .private
        
        localStoredDescriptor.configuration = "Local"
        
        
        container.persistentStoreDescriptions = [
            cloudSyncDescriptor,
            localStoredDescriptor
        ]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // 设置监控icloud更新
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeRemoteChange(_:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator)
        
        return container
    }()
    
    // MARK: 处理icloud同步的信息
    
    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    @objc func storeRemoteChange(_ notification: Notification) {
        // Process persistent history to merge changes from other coordinators.
        historyQueue.addOperation {
            self.processPersistentHistory()
        }
    }
    
    // To fetch change since last update, deduplicate if any new insert data, and save the updated token
    private func processPersistentHistory() {
        print("处理icloud同步数据库!!")
        let taskContext = container.newBackgroundContext()
        taskContext.performAndWait {
            let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
            let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
            request.fetchRequest = historyFetchRequest
            let result = (try? taskContext.execute(request)) as? NSPersistentHistoryResult
            guard let transactions = result?.result as? [NSPersistentHistoryTransaction],
                  !transactions.isEmpty
            else { return }
            
            // 处理新的事件记录对象ID
            var newEventStoredObjectIDs = [NSManagedObjectID]()
            let eventStoredObjectName = EventStored.entity().name
            for transaction in transactions where transaction.changes != nil {
                for change in transaction.changes!
                where change.changedObjectID.entity.name == eventStoredObjectName && change.changeType == .insert {
                    newEventStoredObjectIDs.append(change.changedObjectID)
                }
            }
            if !newEventStoredObjectIDs.isEmpty {
                deduplicateEventStoredAndWait(eventStoredObjectIDs: newEventStoredObjectIDs)
            }
            lastHistoryToken = transactions.last!.token
        }
    }
    
    private func deduplicateEventStoredAndWait(eventStoredObjectIDs: [NSManagedObjectID]) {
        // 去重从icloud同步的事件，只保留 lastUpdateDate 最晚的一版本
        let taskContext = container.backgroundContext()
        taskContext.performAndWait {
            eventStoredObjectIDs.forEach { eventObjectID in
                self.deduplicateEventStoredObject(eventObjectID: eventObjectID, performingContext: taskContext)
            }
            // Save the background context to trigger a notification and merge the result into the viewContext.
            save(context: taskContext)
        }
    }
    private func deduplicateEventStoredObject(eventObjectID: NSManagedObjectID, performingContext: NSManagedObjectContext) {
        guard let event = performingContext.object(with: eventObjectID) as? EventStored else {
            fatalError("###\(#function): Failed to retrieve a valid tag with ID: \(eventObjectID)")
        }
        if event.isCustomEvent {
            // 如果是自定义事件，则不去重，只处理lexue事件
            return
        }
        guard let lexue_event_id = event.lexue_event_id else {
            return
        }
        let fetchRequest: NSFetchRequest<EventStored> = EventStored.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lexue_event_id == %@", lexue_event_id)
        guard var duplicatedEvents = try? performingContext.fetch(fetchRequest), duplicatedEvents.count > 1 else {
            return
        }
        duplicatedEvents.sort { event1, event2 in
            let date1 = event1.lastUpdateDate ?? Date(timeIntervalSince1970: 0)
            let date2 = event2.lastUpdateDate ?? Date(timeIntervalSince1970: 0)
            return date1 > date2
        }
        guard let winner = duplicatedEvents.first else {
            fatalError("###\(#function): Failed to retrieve the first duplicated tag")
        }
        duplicatedEvents.removeFirst()
        removeDuplicatedEvents(duplicatedEvents: duplicatedEvents, winner: winner, performingContext: performingContext)
    }
    
    private func removeDuplicatedEvents(duplicatedEvents: [EventStored], winner: EventStored, performingContext: NSManagedObjectContext) {
        duplicatedEvents.forEach { event in
            defer { performingContext.delete(event) }
            let msgStoredFetch = MessageStored.fetchRequest()
            msgStoredFetch.predicate = NSPredicate(format: "event_uuid == %@", (event.id ?? UUID()) as CVarArg)
            guard var msgs = try? performingContext.fetch(msgStoredFetch) else {
                return
            }
            for msg in msgs {
                print("重新定位消息指向的事件...")
                msg.event_uuid = winner.id
            }
        }
    }
    
    
    static var managedContext: NSManagedObjectContext {
        let context = DataController.shared.container.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    private lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("iLexueHelper", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("###\(#function): Failed to create persistent container URL. Error = \(error)")
            }
        }
        return url.appendingPathComponent("icloud_history_token.data", isDirectory: false)
    }()
    
    private var lastHistoryToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard let token = lastHistoryToken,
                let data = try? NSKeyedArchiver.archivedData( withRootObject: token, requiringSecureCoding: true) else { return }
            
            do {
                try data.write(to: tokenFile)
            } catch {
                print("###\(#function): Failed to write token data. Error = \(error)")
            }
        }
    }
    
    init() {
        if let tokenData = try? Data(contentsOf: tokenFile) {
            do {
                lastHistoryToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: tokenData)
            } catch {
                print("###\(#function): Failed to unarchive NSPersistentHistoryToken. Error = \(error)")
            }
        }
    }
    
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                #if MAIN_APP
                UMAnalyticsSwift.event(eventId: "error_db", attributes: ["error": nsError.localizedDescription])
                
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "保存数据库失败，数据可能出现错误"
                    GlobalVariables.shared.alertContent = nsError.localizedDescription
                    GlobalVariables.shared.showAlert = true
                }
                #endif
            }
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
        ret.messageBody.event_name = origin.event_name
        ret.messageBody.event_uuid = origin.event_uuid
        ret.messageBody.event_starttime = origin.event_starttime
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
                          link_data: String?, link_title: String?, date: Date?, event_name: String?, event_starttime: String?, event_uuid: UUID?, context: NSManagedObjectContext) {
        let msgStored = MessageStored(context: context)
        msgStored.id = UUID()
        msgStored.senderUid = senderUid
        msgStored.type = Int32(type.rawValue)
        msgStored.text_data = text_data
        msgStored.image_data = image_data
        msgStored.link_data = link_data
        msgStored.link_title = link_title
        msgStored.date = date ?? Date()
        msgStored.event_name = event_name
        msgStored.event_starttime = event_starttime
        msgStored.event_uuid = event_uuid
        save(context: context)
    }
    
    // 这个方法是为了方便后期可能要拓展消息类型，可以直接修改MessageBodyItem的内容
    func addMessageStoredFromMsgBody(senderUid: String, msgBody: MessageBodyItem, date: Date?,  context: NSManagedObjectContext) -> MessageStored {
        let msgStored = MessageStored(context: context)
        msgStored.id = UUID()
        msgStored.senderUid = senderUid
        msgStored.type = Int32(msgBody.type.rawValue)
        msgStored.text_data = msgBody.text_data
        msgStored.image_data = msgBody.image_data
        msgStored.link_data = msgBody.link
        msgStored.link_title = msgBody.link_title
        msgStored.date = date ?? Date()
        msgStored.event_name = msgBody.event_name
        msgStored.event_uuid = msgBody.event_uuid
        msgStored.event_starttime = msgBody.event_starttime
        save(context: context)
        return msgStored
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
    
    func addEventStored(isCustomEvent: Bool, event_name: String?, event_description: String?, lexue_id: String?, timestart: Date?, timeusermidnight: Date?, mindaytimestamp: Date?, course_id: String?, course_name: String?, color: Color?, action_url: String?, event_type: String?, instance: Int64?, url: String?, examCourseId: String? = nil, isPeriodEvent: Bool = false, timeend: Date? = nil, lastUpdateDate: Date? = nil, context: NSManagedObjectContext) {
        let eventStored = EventStored(context: context)
        eventStored.id = UUID()
        eventStored.action_url = action_url
        eventStored.color = (color != nil) ? color!.toHex() : Color.green.toHex()
        eventStored.course_id = course_id
        eventStored.course_name = course_name
        eventStored.event_description = event_description
        eventStored.event_type = event_type
        eventStored.instance = instance ?? 0
        eventStored.isCustomEvent = isCustomEvent
        eventStored.lexue_event_id = lexue_id
        eventStored.mindaytimestamp = mindaytimestamp
        eventStored.name = event_name
        eventStored.timestart = timestart
        eventStored.timeusermidnight = timeusermidnight
        eventStored.url = url
        eventStored.finish = false
        eventStored.user_deleted = false
        eventStored.examCourseId = examCourseId
        eventStored.is_period_event = isPeriodEvent
        eventStored.timeend = timeend
        eventStored.lastUpdateDate = lastUpdateDate
        save(context: context)
    }
    
    func GetEventTypeDescription(_ event_type: String) -> String {
        switch event_type {
        case "exam":
            return "考试"
        case "general":
            return "常规"
        case "assignment":
            return "作业"
        case "user":
            return "用户自定事件"
        case "due":
            return "DDL"
        default:
            return "未知"
        }
    }
    
    func findEventByExamCourseId(examCourseId: String, context: NSManagedObjectContext) -> EventStored? {
        let request: NSFetchRequest<EventStored> = EventStored.fetchRequest()
        request.predicate = NSPredicate(format: "examCourseId == %@", examCourseId)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch {
            print("findEventByExamCourseId失败：\(error)")
        }
        return nil
    }
    
    func findEventById(id: UUID, context: NSManagedObjectContext) -> EventStored? {
        let request: NSFetchRequest<EventStored> = EventStored.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch {
            print("查询事件列表失败：\(error)")
        }
        return nil
    }
    
    func findEventStoredByLexueId(lexue_event_id: String, context: NSManagedObjectContext) -> EventStored? {
        let request: NSFetchRequest<EventStored> = EventStored.fetchRequest()
        request.predicate = NSPredicate(format: "lexue_event_id == %@", lexue_event_id)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch {
            print("查询消息列表失败：\(error)")
        }
        return nil
    }
    
    func queryAllEventStored(isDeleted: Bool = false, context: NSManagedObjectContext) -> [EventStored] {
        let request: NSFetchRequest<EventStored> = EventStored.fetchRequest()
        let predicate = NSPredicate(format: "user_deleted == %@", NSNumber(value: isDeleted))
        request.predicate = predicate
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("查询事件列表失败：\(error)")
        }
        
        return [EventStored]()
    }
    
    func queryAllLexueDP_RecordEvent(context: NSManagedObjectContext) -> [LexueDP_RecordEvent] {
        let request: NSFetchRequest<LexueDP_RecordEvent> = LexueDP_RecordEvent.fetchRequest()
        var ret: [LexueDP_RecordEvent] = [LexueDP_RecordEvent]()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("查询LexueDP_RecordEvent失败1：\(error)")
        }
        return ret
    }
    
    func getLexueDP_RecordEventByUUID(eventUUID: UUID, context: NSManagedObjectContext) -> LexueDP_RecordEvent? {
        let request: NSFetchRequest<LexueDP_RecordEvent> = LexueDP_RecordEvent.fetchRequest()
        request.predicate = NSPredicate(format: "eventUUID == %@", eventUUID as CVarArg)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch {
            print("查询LexueDP_RecordEvent失败2：\(error)")
        }
        return nil
    }
    
    func addLexueDP_RecordEvent(eventUUID: UUID, context: NSManagedObjectContext) {
        let record = LexueDP_RecordEvent(context: context)
        record.eventUUID = eventUUID
        save(context: context)
    }
    
    func queryAllLexueDP_RecordNotification(context: NSManagedObjectContext) -> [LexueDP_RecordNotification] {
        let request: NSFetchRequest<LexueDP_RecordNotification> = LexueDP_RecordNotification.fetchRequest()
        var ret: [LexueDP_RecordNotification] = [LexueDP_RecordNotification]()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("查询LexueDP_RecordNotification失败1：\(error)")
        }
        return ret
    }
    
    func getLexueDP_RecordNotificationByID(id: String, context: NSManagedObjectContext) -> LexueDP_RecordNotification? {
        let request: NSFetchRequest<LexueDP_RecordNotification> = LexueDP_RecordNotification.fetchRequest()
        request.predicate = NSPredicate(format: "notificationID == %@", id)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch {
            print("查询LexueDP_RecordNotification失败2：\(error)")
        }
        return nil
    }
    
    func addLexueDP_RecordNotification(id: String, context: NSManagedObjectContext) {
        let record = LexueDP_RecordNotification(context: context)
        record.notificationID = id
        save(context: context)
    }
    
    func queryAllLexueDP_RecordNotifiedEvent(context: NSManagedObjectContext) -> [LexueDP_RecordNotifiedEvent] {
        let request: NSFetchRequest<LexueDP_RecordNotifiedEvent> = LexueDP_RecordNotifiedEvent.fetchRequest()
        var ret: [LexueDP_RecordNotifiedEvent] = [LexueDP_RecordNotifiedEvent]()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("查询LexueDP_RecordNotifiedEvent失败1：\(error)")
        }
        return ret
    }
    
    func getLexueDP_RecordNotifiedEvent(eventUUID: UUID, context: NSManagedObjectContext) -> [LexueDP_RecordNotifiedEvent] {
        let request: NSFetchRequest<LexueDP_RecordNotifiedEvent> = LexueDP_RecordNotifiedEvent.fetchRequest()
        request.predicate = NSPredicate(format: "eventUUID == %@", eventUUID as CVarArg)
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("查询LexueDP_RecordNotifiedEvent失败2：\(error)")
        }
        return []
    }
    
    func addLexueDP_RecordNotifiedEvent(eventUUID: UUID, notifiedDate: Date, context: NSManagedObjectContext) {
        let record = LexueDP_RecordNotifiedEvent(context: context)
        record.eventUUID = eventUUID
        record.notifiedTime = notifiedDate
        save(context: context)
    }
    
    func addFavoriteURL(title: String, url: String, from_course_id: String?, from_course_name: String?, context: NSManagedObjectContext) {
        let favoriteUrlStore = FavoriteURLStored(context: context)
        favoriteUrlStore.id = UUID()
        favoriteUrlStore.title = title
        favoriteUrlStore.url = url
        favoriteUrlStore.favorite_date = .now
        favoriteUrlStore.from_course_id = from_course_id
        favoriteUrlStore.from_course_name = from_course_name
        save(context: context)
    }
    
    func getFavoriteURLs(context: NSManagedObjectContext) -> [FavoriteURLStored] {
        let request: NSFetchRequest<FavoriteURLStored> = FavoriteURLStored.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            
        }
        return []
    }
    
    func queryFavoriteURLByID(uuid: UUID, context: NSManagedObjectContext) -> FavoriteURLStored? {
        let request: NSFetchRequest<FavoriteURLStored> = FavoriteURLStored.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            } else {
                return nil
            }
        } catch {
            print("查询queryFavoriteURLByID失败：\(error)")
        }
        return nil
    }
}


extension FavoriteURLStored {
    func GetDisplayName() -> String {
        return title ?? "未命名"
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
