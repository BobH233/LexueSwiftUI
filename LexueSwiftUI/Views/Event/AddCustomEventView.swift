//
//  AddCustomEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import SwiftUI

struct AddCustomEventView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    
    
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var startDate = Date.now
    @State private var courseList = CourseManager.shared.CourseDisplayList
    @State private var withCourse: Bool = false
    @State private var selectCourseId: String = ""
    @State private var color: Color = .blue
    
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
                DatePicker(selection: $startDate, in: Date.now..., displayedComponents: [.date, .hourAndMinute]) {
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
                .onAppear {
                    if let firstCourse = courseList.first {
                        selectCourseId = firstCourse.id
                    }
                }
            }
            
            Button("添加日程") {
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
                DataController.shared.addEventStored(isCustomEvent: true, event_name: eventName, event_description: description, lexue_id: nil, timestart: startDate, timeusermidnight: nil, mindaytimestamp: startDate, course_id: courseId, course_name: courseName, color: color, action_url: nil, event_type: eventType, instance: nil, url: nil, context: managedObjContext)
                dismiss()
            }
        }
        .onAppear {
            if let after_1h_time = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) {
                startDate = after_1h_time
            }
        }
        .navigationTitle("添加日程")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddCustomEventView()
}
