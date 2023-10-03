//
//  LexueDataProvider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import Foundation
import CoreData

/**
        乐学数据提供，主要是乐学的铃铛通知消息
        还有
 */
class LexueDataProvider: DataProvider {
    var providerId: String {
        return "lexue_service"
    }
    
    func get_default_enabled() -> Bool {
        return true
    }
    
    func get_default_allowMessage() -> Bool {
        return true
    }
    
    func get_default_allowNotification() -> Bool {
        return true
    }
    
    var enabled: Bool = true
    var allowMessage: Bool = true
    var allowNotification: Bool = true
    
    var msgRequestList: [PushMessageRequest] = []
    
    let lexue_service_uid = "lexue_service"
    let lexue_originName = "乐学"
    func get_priority() -> TaskPriority {
        return .medium
    }
    
    func info() -> DataProviderInfo {
        return DataProviderInfo(providerId: "provider.lexue", providerName: "乐学数据", description: "提供乐学通知提醒、新增事件提醒以及临期事件提醒等功能", author: "BobH")
    }
    
    func GetCourseContactId(_ courseId: String) -> String {
        return "lexue_course_\(courseId)"
    }
    func GetFullDisplayTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日 HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func HandleNewEvent(event: EventStored) {
        if event.isCustomEvent {
            // 自己添加的事件，不处理
            return
        }
        if !SettingStorage.shared.event_newEventNotification {
            // 如果设置了不提醒，那也不处理
            return
        }
        if let courseId = event.course_id, let courseName = event.course_name {
            // 这样就可以推送消息了
            var msg = MessageBodyItem(type: .new_event_notification)
            msg.event_name = event.name!
            msg.event_uuid = event.id
            msg.event_starttime = GetFullDisplayTime(event.timestart!)
            
            // 方便被检索到
            msg.text_data = "[事件提醒] \(event.name!)"
            if allowMessage {
                // MessageManager.shared.PushMessageWithContactCreation(senderUid: GetCourseContactId(courseId), contactOriginNameIfMissing: courseName, contactTypeIfMissing: .course, msgBody: msg, date: Date(), context: DataController.shared.container.viewContext)
                msgRequestList.append(PushMessageRequest(senderUid: GetCourseContactId(courseId), contactOriginNameIfMissing: courseName, contactTypeIfMissing: .course, msgBody: msg, date: Date()))
            }
        } else {
            // 如果不对应具体某个课程，那么就由乐学来发送
            var msg = MessageBodyItem(type: .new_event_notification)
            msg.event_name = event.name!
            msg.event_uuid = event.id
            msg.event_starttime = GetFullDisplayTime(event.timestart!)
            // 方便被检索到
            msg.text_data = "[事件提醒] \(event.name!)"
            if allowMessage {
                // MessageManager.shared.PushMessageWithContactCreation(senderUid: lexue_service_uid, contactOriginNameIfMissing: lexue_originName, contactTypeIfMissing: .msg_provider, msgBody: msg, date: Date(), notify: allowNotification, context: DataController.shared.container.viewContext)
                msgRequestList.append(PushMessageRequest(senderUid: lexue_service_uid, contactOriginNameIfMissing: lexue_originName, contactTypeIfMissing: .msg_provider, msgBody: msg, date: Date()))
            }
        }
    }
    
    func CheckEventUpdate(context: NSManagedObjectContext) {
        // 检查是否有新增事件
        let records = DataController.shared.queryAllLexueDP_RecordEvent(context: context)
        let events = DataController.shared.queryAllEventStored(context: context)
        var recordedSet = Set<UUID>()
        if records.count == 0 {
            // 新使用的，第一次，所以直接添加进去事件即可
            for event in events {
                print("First time: push \(event.name!)")
                DataController.shared.addLexueDP_RecordEvent(eventUUID: event.id!, context: context)
            }
        } else {
            for record in records {
                recordedSet.insert(record.eventUUID!)
            }
            for event in events {
                if !recordedSet.contains(event.id!) {
                    // 检测到新的事件
                    print("New event!:  \(event.name!)")
                    DataController.shared.addLexueDP_RecordEvent(eventUUID: event.id!, context: context)
                    HandleNewEvent(event: event)
                }
            }
        }
    }
    
    func HandleNewNotification(notification: LexueAPI.LexueNotification) {
        var msg = MessageBodyItem(type: .text)
        msg.text_data = "\(notification.subject ?? "")\n (\(GetFullDisplayTime(notification.timecreated ?? Date()))) "
        msgRequestList.append(PushMessageRequest(senderUid: lexue_service_uid, contactOriginNameIfMissing: lexue_originName, contactTypeIfMissing: .msg_provider, msgBody: msg, date: Date()))
    }
    
    var curPopupNotifications = [LexueAPI.LexueNotification]()
    
    // 检查乐学的站内小铃铛消息
    func CheckNotificationUpdate(context: NSManagedObjectContext) {
        let records = DataController.shared.queryAllLexueDP_RecordNotification(context: context)
        var recordedSet = Set<String>()
        if records.count == 0 {
            // 新使用的，第一次，所以直接添加进去事件即可
            for notification in curPopupNotifications {
                print("First time: push \(notification.subject!)")
                DataController.shared.addLexueDP_RecordNotification(id: notification.id, context: context)
            }
        } else {
            for record in records {
                recordedSet.insert(record.notificationID!)
            }
            for notification in curPopupNotifications {
                if let read = notification.read, read {
                    // 已读消息不用处理
                    continue
                }
                if !recordedSet.contains(notification.id) {
                    // 检测到新的事件
                    print("New notification!:  \(notification.subject!)")
                    DataController.shared.addLexueDP_RecordNotification(id: notification.id, context: context)
                    HandleNewNotification(notification: notification)
                }
            }
        }
    }
    
    func CheckNearbyEvent(context: NSManagedObjectContext) {
        if !SettingStorage.shared.event_enableNotification {
            // 如果没开启提前提醒则返回
            return
        }
        print("Checking NearbyEvent")
        let events = DataController.shared.queryAllEventStored(context: context)
        let now = Date.now
        var futureDate = now
        if let tmp1 = Calendar.current.date(byAdding: .hour, value: SettingStorage.shared.event_preHour, to: futureDate), let tmp2 = Calendar.current.date(byAdding: .minute, value: SettingStorage.shared.event_preMinute, to: tmp1) {
            futureDate = tmp2
        } else {
            print("Unknow error when check nearby event...")
        }
        // print(now)
        // print(futureDate)
        
        
        
        for event in events {
            if event.timestart == nil {
                continue
            }
            if let date = event.timestart, date < now {
                // 过期事件，不管
                continue
            }
            if event.finish {
                // 完成事件，不管
                continue
            }
            if futureDate < event.timestart! {
                // 还没到要通知的时候，不管
                continue
            }
            // 检查之前是否通知过了，还有要注意即便是通知过了，用户也可能在那之后更改了设置里的提前时间数，因此要判断之前通知的时候的 日期+偏移 是否覆盖了事件
            // 事件经过编辑过后，也应该重新通知，所以我在编辑事件的时候需要把已经通知的记录全部删了
            var notified = false
            let notifiedEventRecords = DataController.shared.getLexueDP_RecordNotifiedEvent(eventUUID: event.id!, context: context)
            for notifiedEventRecord in notifiedEventRecords {
                if let tmp1 = Calendar.current.date(byAdding: .hour, value: SettingStorage.shared.event_preHour, to: notifiedEventRecord.notifiedTime!), let tmp2 = Calendar.current.date(byAdding: .minute, value: SettingStorage.shared.event_preMinute, to: tmp1) {
                    if tmp2 >= event.timestart! {
                        // 说明之前通知的已经覆盖了这个事件
                        notified = true
                        break
                    }
                }
            }
            // print("eventid: \(event.id!) notified: \(notified)")
            if notified {
                // 已经通知过，不用再通知了
                continue
            }
            var msg = MessageBodyItem(type: .due_event_notification)
            msg.event_name = event.name!
            msg.event_uuid = event.id
            msg.event_starttime = GetFullDisplayTime(event.timestart!)
            msgRequestList.append(PushMessageRequest(senderUid: lexue_service_uid, contactOriginNameIfMissing: lexue_originName, contactTypeIfMissing: .msg_provider, msgBody: msg, date: Date()))
            DataController.shared.addLexueDP_RecordNotifiedEvent(eventUUID: event.id!, notifiedDate: .now, context: context)
        }
    }
    
    func refresh() async {
        if !enabled {
            return
        }
        
        // 刷新站内消息
        let getNotificationResult = await LexueAPI.shared.GetPopupNotifications(GlobalVariables.shared.cur_lexue_context, sesskey: GlobalVariables.shared.cur_lexue_sessKey, selfUserId: GlobalVariables.shared.cur_user_info.userId)
        switch getNotificationResult {
        case .success(let result):
            curPopupNotifications = result
            await DataController.shared.container.performBackgroundTask { (context) in
                self.CheckNotificationUpdate(context: context)
            }
        case .failure(_):
            print("获取站内消息失败!")
        }
        
        
        // 刷新乐学新的事件
        await DataController.shared.container.performBackgroundTask { (context) in
            self.CheckEventUpdate(context: context)
        }
        
        // 刷新到期提醒事件
        await DataController.shared.container.performBackgroundTask{ (context) in
            self.CheckNearbyEvent(context: context)
        }
    }
    
}
