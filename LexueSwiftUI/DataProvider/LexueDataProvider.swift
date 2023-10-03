//
//  LexueDataProvider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import Foundation

/**
        乐学数据提供，主要是乐学的铃铛通知消息
        还有
 */
class LexueDataProvider: DataProvider {
    let lexue_service_uid = "lexue_service"
    let lexue_originName = "乐学"
    func get_priority() -> TaskPriority {
        return .medium
    }
    
    func info() -> DataProviderInfo {
        return DataProviderInfo(providerId: "provider.lexue", providerName: "乐学数据", usage: "提供乐学通知提醒、新增事件提醒以及临期事件提醒等功能", author: "BobH")
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
            MessageManager.shared.PushMessageWithContactCreation(senderUid: GetCourseContactId(courseId), contactOriginNameIfMissing: courseName, contactTypeIfMissing: .course, msgBody: msg, date: Date(), context: DataController.shared.container.viewContext)
            if let url = event.action_url {
                var url_msg = MessageBodyItem(type: .link)
                url_msg.link_title = event.name!
                url_msg.link = url
                MessageManager.shared.PushMessageWithContactCreation(senderUid: GetCourseContactId(courseId), contactOriginNameIfMissing: courseName, contactTypeIfMissing: .course, msgBody: url_msg, date: Date(), context: DataController.shared.container.viewContext)
            }
        } else {
            // 如果不对应具体某个课程，那么就由乐学来发送
            var msg = MessageBodyItem(type: .event_notification)
            msg.event_name = event.name!
            msg.event_uuid = event.id
            msg.event_starttime = GetFullDisplayTime(event.timestart!)
            MessageManager.shared.PushMessageWithContactCreation(senderUid: lexue_service_uid, contactOriginNameIfMissing: lexue_originName, contactTypeIfMissing: .msg_provider, msgBody: msg, date: Date(), context: DataController.shared.container.viewContext)
        }
    }
    
    func CheckEventUpdate() async {
        // 检查是否有新增事件
        let records = DataController.shared.queryAllLexueDP_RecordEvent(context: DataController.shared.container.viewContext)
        let events = DataController.shared.queryAllEventStored(context: DataController.shared.container.viewContext)
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
                // TODO: debug delete
                HandleNewEvent(event: event)
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
        await CheckEventUpdate()
    }
    
}
