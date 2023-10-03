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
            var msg = MessageBodyItem(type: .event_notification)
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
            var msg = MessageBodyItem(type: .event_notification)
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
                DataController.shared.addLexueDP_RecordEvent(eventUUID: event.id!, context: DataController.shared.container.viewContext)
            }
        } else {
            for record in records {
                recordedSet.insert(record.eventUUID!)
            }
            for event in events {
                if !recordedSet.contains(event.id!) {
                    // 检测到新的事件
                    print("New event!:  \(event.name!)")
                    DataController.shared.addLexueDP_RecordEvent(eventUUID: event.id!, context: DataController.shared.container.viewContext)
                    HandleNewEvent(event: event)
                }
            }
        }
    }
    
    func refresh() async {
        if !enabled {
            return
        }
        await DataController.shared.container.performBackgroundTask { (context) in
            self.CheckEventUpdate(context: context)
        }
    }
    
}
