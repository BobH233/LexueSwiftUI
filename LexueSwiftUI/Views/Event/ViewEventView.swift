//
//  ViewEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import SwiftUI
import EventKitUI

// https://betterprogramming.pub/eventkitui-in-ios-17-c83868464a8f
struct SystemEventEditViewController: UIViewControllerRepresentable {
    @Binding var event_name: String
    @Binding var start_date: Date
    @Binding var end_date: Date
    @Binding var notes: String?
    @Binding var location: String?
    @Binding var store: EKEventStore
    @Environment(\.presentationMode) var presentationMode
    private var event: EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = event_name
        event.startDate = start_date
        event.endDate = end_date
        if let notes = notes {
            event.notes = notes
        }
        if let location = location {
            event.location = location
        }
        return event
    }
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = event
        eventEditViewController.eventStore = store
        eventEditViewController.editViewDelegate = context.coordinator
        return eventEditViewController
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: SystemEventEditViewController
        
        init(_ controller: SystemEventEditViewController) {
            self.parent = controller
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ViewEventView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State var event_uuid: UUID
    @State var event_obj: EventStored? = nil
    
    @State var showEditView: Bool = false
    
    @State var editable: Bool = true
    
    @State var showAddSystemEvent: Bool = false
    @State var addSystemEventTitle: String = ""
    @State var addSystemEventNote: String?
    @State var addSystemEventStartDate: Date = .now
    @State var addSystemEventEndDate: Date = .now
    @State var addSystemEventLocation: String?
    
    @State var eventStore = EKEventStore()
    
    
    // 是否已经是到期事件了
    func IsExpired(event: EventStored) -> Bool {
        return event.timestart ?? Date() < Date.now
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
                                guard let time_start = event_obj!.timestart else {
                                    return
                                }
                                addSystemEventTitle = event_obj!.name ?? ""
                                addSystemEventNote = event_obj!.event_description ?? ""
                                addSystemEventEndDate = time_start
                                if let tmp1 = Calendar.current.date(byAdding: .hour, value: -SettingStorage.shared.event_preHour, to: time_start), let tmp2 = Calendar.current.date(byAdding: .minute, value: -SettingStorage.shared.event_preMinute, to: tmp1) {
                                    addSystemEventStartDate = tmp2
                                } else {
                                    print("Unknow error when adding event to system event...")
                                    addSystemEventEndDate = time_start
                                }
                                addSystemEventLocation = event_obj!.course_name ?? ""
                                
                                if #available(iOS 17.0, *) {
                                    // 17.0 用这个获取权限
                                    // 实际上wwdc23说17.0调用EventKitUI不用询问权限...不过还是加上吧
                                    eventStore.requestWriteOnlyAccessToEvents { granted, error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }
                                        if granted {
                                            DispatchQueue.main.async {
                                                showAddSystemEvent = true
                                            }
                                        }
                                    }
                                } else {
                                    // 17.0 以下用这个获取权限
                                    eventStore.requestAccess(to: .event) { granted, error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }
                                        if granted {
                                            DispatchQueue.main.async {
                                                showAddSystemEvent = true
                                            }
                                        }
                                    }
                                }
                            }) {
                                Text("添加到我的日历")
                            }
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
                if event_obj!.course_id != nil {
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
            } else {
                Text("没有找到该事件，可能你已经将其删除")
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showAddSystemEvent, content: {
            SystemEventEditViewController(event_name: $addSystemEventTitle, start_date: $addSystemEventStartDate, end_date: $addSystemEventEndDate, notes: $addSystemEventNote, location: $addSystemEventLocation, store: $eventStore)
        })
        .onChange(of: showEditView) { newVal in
            if !newVal {
                dismiss()
            }
        }
        .onAppear {
            if let event = DataController.shared.findEventById(id: event_uuid, context: managedObjContext) {
                event_obj = event
            } else {
                editable = false
            }
        }
        .navigationBarItems(trailing:
                                Button(action: {
            self.showEditView.toggle()
        }) {
            Image(systemName: "square.and.pencil")
        }
            .disabled(!editable)
        )
        .navigationTitle("浏览事件")
        .navigationBarTitleDisplayMode(.inline)
        
        NavigationLink("", isActive: $showEditView, destination: {
            EditEventView(event_uuid: event_uuid)
        })
        .hidden()
    }
}
