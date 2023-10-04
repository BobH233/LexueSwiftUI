//
//  EditEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import SwiftUI
import CoreData


struct EditEventView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State var event_uuid: UUID
    @State var event_obj: EventStored? = nil
    
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var startDate = Date.now
    @State private var courseList = CourseManager.shared.CourseDisplayList
    @State private var withCourse: Bool = false
    @State private var selectCourseId: String = ""
    @State private var color: Color = .blue
    @State private var showDeleteAlert: Bool = false
    
    // 有 作业 assignment 考试 exam 常规 general
    @State private var eventType: String = "assignment"
    
    func GetCourseName(_ id: String) -> String? {
        for course in courseList {
            if course.id == id {
                return course.fullname
            }
        }
        return "未知"
    }
    
    var body: some View {
        Form {
            if event_obj != nil {
                if event_obj!.isCustomEvent {
                    Section("基本设置") {
                        HStack {
                            Text("事件名称")
                            Spacer()
                            TextField("输入事件名称", text: $eventName)
                        }
                        HStack {
                            Text("事件备注")
                            Spacer()
                            TextField("输入事件备注(如地点、人数等)", text: $eventDescription)
                        }
                        DatePicker(selection: $startDate, displayedComponents: [.date, .hourAndMinute]) {
                            Text("时间")
                        }
                        ColorPicker("强调色", selection: $color)
                        Picker("类型", selection: $eventType) {
                            Text("常规")
                                .tag("general")
                            Text("作业")
                                .tag("assignment")
                            Text("考试")
                                .tag("exam")
                        }
                    }
                    if courseList.count > 0 {
                        Section("关联课程") {
                            Toggle("关联课程", isOn: $withCourse)
                            if withCourse {
                                Picker("课程", selection: $selectCourseId) {
                                    ForEach(courseList) { item in
                                        Text("\(item.fullname ?? "")")
                                            .tag(item.id)
                                    }
                                }
                            }
                        }
                    }
                    Section("操作") {
                        Button("修改日程") {
                            if eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                globalVar.alertTitle = "事件名称为空"
                                globalVar.alertContent = "请至少指定事件名称"
                                globalVar.showAlert = true
                                return
                            }
                            let eventName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let description = eventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                            let courseId = withCourse ? selectCourseId : nil
                            let courseName = withCourse ? GetCourseName(selectCourseId) : nil
                            let to_update = DataController.shared.findEventById(id: event_uuid, context: managedObjContext)
                            to_update?.name = eventName
                            to_update?.timestart = startDate
                            to_update?.event_description = description
                            to_update?.event_type = eventType
                            to_update?.course_id = courseId
                            to_update?.course_name = courseName
                            to_update?.color = color.toHex()
                            DataController.shared.save(context: managedObjContext)
                            // 事件经过编辑过后，也应该重新通知，所以我在编辑事件的时候需要把已经通知的记录全部删了
                            print("eventid: \(event_uuid)")
                            let notifiedRecords = DataController.shared.getLexueDP_RecordNotifiedEvent(eventUUID: event_uuid, context: managedObjContext)
                            for notifiedRecord in notifiedRecords {
                                managedObjContext.delete(notifiedRecord)
                            }
                            DataController.shared.save(context: managedObjContext)
                            dismiss()
                        }
                        Button("删除日程") {
                            showDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("删除确认"),
                                message: Text("删除这个事件后，你将不再能够收到这则事件的到期提醒，也无法再查看这个事件，确认删除吗？"),
                                primaryButton: .destructive(Text("确定").foregroundColor(.red)) {
                                    let to_delete = DataController.shared.findEventById(id: event_uuid, context: managedObjContext)
                                    if let to_delete = to_delete {
                                        managedObjContext.delete(to_delete)
                                    }
                                    DataController.shared.save(context: managedObjContext)
                                    dismiss()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                } else {
                    Section("基本设置") {
                        ColorPicker("强调色", selection: $color)
                    }
                    Button("修改日程") {
                        let to_update = DataController.shared.findEventById(id: event_uuid, context: managedObjContext)
                        to_update?.color = color.toHex()
                        DataController.shared.save(context: managedObjContext)
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("编辑事件")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let firstCourse = courseList.first {
                selectCourseId = firstCourse.id
            }
            if let event = DataController.shared.findEventById(id: event_uuid, context: managedObjContext) {
                event_obj = event
                if let event_obj = event_obj {
                    if event_obj.isCustomEvent {
                        eventName = event_obj.name!
                        eventDescription = event_obj.event_description!
                        startDate = event_obj.timestart!
                        if let courseId = event_obj.course_id {
                            withCourse = true
                            selectCourseId = courseId
                        }
                        color = Color(hex: event_obj.color!) ?? .green
                        eventType = event_obj.event_type!
                    } else {
                        color = Color(hex: event_obj.color!) ?? .green
                    }
                }
            }
        }
    }
}

