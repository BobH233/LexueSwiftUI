//
//  ViewEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import SwiftUI

struct ViewEventView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State var event_uuid: UUID
    @State var event_obj: EventStored? = nil
    
    @State var showEditView: Bool = false
    
    // 是否已经是到期事件了
    func IsExpired(event: EventStored) -> Bool {
        return event.timestart! < Date.now
    }
    
    func GetCourseById(_ id: String) -> CourseShortInfo? {
        let ret = DataController.shared.queryCourseCacheStoredById(id: id, context: managedObjContext)
        return ret
    }
    
    func GetFullDisplayTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日 HH:mm"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        Form {
            if event_obj != nil {
                Section() {
                    if IsExpired(event: event_obj!) {
                        Text("事件已到期")
                    } else {
                        if event_obj!.finish {
                            Button(action: {
                                withAnimation {
                                    EventManager.shared.FinishEvent(id: event_uuid, isFinish: false, context: managedObjContext)
                                }
                                dismiss()
                            }) {
                                Text("设置为未完成")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Button(action: {
                                withAnimation {
                                    EventManager.shared.FinishEvent(id: event_uuid, isFinish: true, context: managedObjContext)
                                }
                                dismiss()
                            }) {
                                Text("设置为已完成")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                Section("事件信息") {
                    if let name = event_obj!.name {
                        HStack {
                            Text("事件名")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(name)
                                .foregroundColor(.secondary)
                        }
                    }
                    if let description = event_obj!.event_description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HStack {
                            Text("备注")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(GetHtmlText(event_obj!.event_description!))
                                .foregroundColor(.secondary)
                        }
                    }
                    if let mindaytimestamp = event_obj!.mindaytimestamp {
                        HStack {
                            Text("开启时间")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(GetFullDisplayTime(mindaytimestamp))
                                .foregroundColor(.secondary)
                        }
                    }
                    if let timestart = event_obj!.timestart {
                        HStack {
                            Text("到期时间")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(GetFullDisplayTime(timestart))
                                .foregroundColor(.secondary)
                        }
                    }
                    if let event_type = event_obj!.event_type {
                        HStack {
                            Text("事件类型")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(DataController.shared.GetEventTypeDescription(event_type))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                if !event_obj!.isCustomEvent {
                    Section("操作") {
                        if let courseId = event_obj!.course_id, let courseInfo = GetCourseById(courseId) {
                            NavigationLink("\(courseInfo.fullname ?? "")") {
                                CourseDetailView(courseId: courseId, courseInfo: courseInfo, courseName: courseInfo.fullname ?? "")
                            }
                        }
                        if let action_url = event_obj!.action_url {
                            NavigationLink("打开事件链接") {
                                LexueBroswerView(url: action_url)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: showEditView) { newVal in
            if !newVal {
                dismiss()
            }
        }
        .onAppear {
            if let event = DataController.shared.findEventById(id: event_uuid, context: managedObjContext) {
                event_obj = event
            } else {
                dismiss()
                globalVar.alertTitle = "无法找到这个事件\(event_uuid.uuidString)"
                globalVar.alertContent = "按理来说这不应该发生...请反馈bug"
                globalVar.showAlert = true
            }
        }
        .navigationBarItems(trailing:
                                Button(action: {
            self.showEditView.toggle()
        }) {
            Image(systemName: "square.and.pencil")
        }
        )
        .navigationTitle("浏览事件")
        .navigationBarTitleDisplayMode(.inline)
        
        NavigationLink("", isActive: $showEditView, destination: {
            EditEventView(event_uuid: event_uuid)
        })
        .hidden()
    }
}
