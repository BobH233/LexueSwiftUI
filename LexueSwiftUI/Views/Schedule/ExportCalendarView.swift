//
//  ExportCalendarView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/26.
//
//  导出到iOS系统日历的选项

import SwiftUI
import EventKit

struct ExportCalendarView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var calendarName: String = "i乐学助手课程表"
    @State var enableNotification: Bool = true
    @State var selectedHour: Int = 0
    @State var selectedMinute: Int = 15
    @State private var color: Color = .blue
    @Environment(\.dismiss) var dismiss
    
    @State var selectableCourses: [CourseExportSelection] = []
    @State private var showCourseSelection = false
    
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertContent: String = ""
    
    var selectedEventsCount: Int {
        selectableCourses.filter { $0.isSelected }.reduce(0) { $0 + $1.events.count }
    }
    
    func ExportToSystemCalendar() {
        Task {
            var successSave = 0
            if #available(iOS 17.0, *) {
                let ret = try await iOSCalendarManager.shared.eventStore.requestFullAccessToEvents()
                print("ret", ret)
            }
            
            guard !calendarName.isEmpty else {
                DispatchQueue.main.async {
                    alertTitle = "日历名称为空"
                    alertContent = "必须指定日历名称！"
                    showAlert = true
                }
                return
            }
            guard let calendar = await iOSCalendarManager.shared.AddNewCalendar(calendarName: calendarName, calendarColor: UIColor(color)) else {
                DispatchQueue.main.async {
                    alertTitle = "新建日历失败"
                    alertContent = "请前往设置，确保你已经打开了乐学助手\"完全访问日历\"的权限，并重试"
                    showAlert = true
                }
                return
            }
            
            let eventsToExport = selectableCourses.filter { $0.isSelected }.flatMap { $0.events }
            
            for event in eventsToExport {
                let sys_event = EKEvent(eventStore: iOSCalendarManager.shared.eventStore)
                sys_event.title = event.title
                sys_event.location = event.location
                sys_event.startDate = event.StartDate
                sys_event.endDate = event.EndDate
                if enableNotification {
                    let alarm = EKAlarm(relativeOffset: -60 * (Double(selectedHour) * 60 + Double(selectedMinute)))
                    sys_event.addAlarm(alarm)
                }
                sys_event.notes = event.note
                sys_event.calendar = calendar
                do {
                    try iOSCalendarManager.shared.eventStore.save(sys_event, span: .thisEvent)
                    successSave += 1
                } catch {
                    print("Error saving event: \(error)")
                }
            }
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                GlobalVariables.shared.alertTitle = "导出完毕"
                GlobalVariables.shared.alertContent = "总共\(eventsToExport.count)个日程，导出成功\(successSave)个日程，请前往日历检查是否有误"
                GlobalVariables.shared.showAlert = true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("导入设置") {
                    HStack {
                        Text("新建日历名称:")
                        Spacer()
                        TextField("必填，输入导入日历的名称", text: $calendarName)
                    }
                    ColorPicker("强调色", selection: $color)
                    
                    Button(action: {
                        showCourseSelection = true
                    }) {
                        HStack {
                            Text("课程")
                            Spacer()
                            Text("\(selectableCourses.filter { $0.isSelected }.count) / \(selectableCourses.count) 项")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    .sheet(isPresented: $showCourseSelection) {
                        CourseSelectionView(courses: $selectableCourses)
                    }
                    
                    Text("一共有\(selectedEventsCount)个独立课程事件")
                        .foregroundColor(.secondary)
                }
                Section() {
                    Toggle("开启提前提醒", isOn: $enableNotification)
                    if enableNotification {
                        Stepper(value: $selectedHour, in: 0...23) {
                            Text("\(selectedHour) 小时")
                        }
                        Stepper(value: $selectedMinute, in: 0...59) {
                            Text("\(selectedMinute) 分钟")
                        }
                    }
                } header: {
                    Text("提前提醒时间")
                } footer: {
                    Text("设定导入的课程提前多久提醒你上课")
                }
            }
            .navigationTitle("导出到系统日历")
            .navigationBarItems(trailing:
                                    Button(action: {
                ExportToSystemCalendar()
            }) {
                Text("导出")
                    .foregroundColor(.blue)
            }
            )
            .foregroundColor(nil)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    let allEvents = ScheduleManager.shared.GenerateCalendarEvents(context: managedObjContext)
                    let groupedEvents = Dictionary(grouping: allEvents, by: { $0.courseId })
                    
                    let sortedCourses = groupedEvents.values.sorted { $0[0].courseName < $1[0].courseName }
                    
                    DispatchQueue.main.async {
                        self.selectableCourses = sortedCourses.map { events in
                            CourseExportSelection(id: events[0].courseId, courseName: events[0].courseName, events: events, isSelected: true)
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertContent), dismissButton: .default(Text("确定")))
            }
        }
    }
}

#Preview {
    ExportCalendarView()
}
