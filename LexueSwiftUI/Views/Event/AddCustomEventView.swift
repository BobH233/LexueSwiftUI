//
//  AddCustomEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import SwiftUI
import AudioToolbox

struct AddCustomEventView: View {
    let GPTInstruction = """
    你现在是一个json格式文本生成器，输出json供程序去解析，用户给你的指令是设置一个提醒事项。你输出的json对象文本需要包含一下几个内容：（1）提醒事项名称（event_name），这个可以你根据用户的指令自行决定（2）提醒事项的发生时间(event_time)，这是一个文本，格式为“年-月-日 时:分:秒”，我会告诉你现在的时间，然后你自己根据用户的指令决定输出的时间文本（3）提醒事项的备注（event_description）这个你根据用户的指令自行决定，比如事件发生的地点，参加人等等（4）错误信息（error），假如用户输入了其他无关的东西，或者给你的指令你无法理解，请你在这里以字符串输出错误信息，如果没有错误，这里请输出null。（5）给用户说的话（comment），这里输出你为顾客安排了事件过后，想对顾客说的话，可以自由发挥，如果没有可以保持null。
    """
    
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    
    
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventUrl: String = ""
    @State private var startDate = Date.now
    @State private var courseList = CourseManager.shared.CourseDisplayList
    @State private var withCourse: Bool = false
    @State private var selectCourseId: String = ""
    @State private var color: Color = .blue
    
    @State private var useGpt: Bool = false
    @State private var gptAskContent: String = ""
    @State private var gptThinking: Bool = false
    @State private var gptComment: String = ""
    @State private var gptError: String = ""
    
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
    
    func AskGpt() {
        if gptAskContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            globalVar.alertTitle = "文字描述不能为空"
            globalVar.alertContent = "请给定指令比如：明天下午六点提醒我吃北理烤鹅"
            globalVar.showAlert = true
            return
        }
        gptThinking = true
        gptError = ""
        gptComment = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日HH:mm分 EEEE"
        let formattedTime = dateFormatter.string(from: .now)
        let askContent = "现在的时间是\(formattedTime)，用户给你的指令是：“\(gptAskContent)”，直接输出json内容，不要有多余的话和补充"
        print(askContent)
        gptAskContent = ""
        UMAnalyticsSwift.event(eventId: "use_gpt", attributes: ["username": GlobalVariables.shared.cur_user_info.stuId])
        Task {
            let result = await GPTApiFree.shared.RequestGPT(param: GPTApiFree.GPTRequestParam(modle: "gpt-3.5-turbo-16k",
                                                                                              messages: [
                GPTApiFree.GPTMessage(role: "system", content: GPTInstruction),
                GPTApiFree.GPTMessage(role: "user", content: askContent)
            ]))
            switch result {
            case .success(let success_res):
                // 解析返回的内容
                if success_res.choices.count == 0 {
                    DispatchQueue.main.async {
                        gptThinking = false
                        globalVar.alertTitle = "请求GPT接口出错"
                        globalVar.alertContent = "可能是网络问题，您可以尝试再试一次..."
                        globalVar.showAlert = true
                    }
                    return
                }
                var retJson = success_res.choices[0].message.content
                // 只取出json部分内容，不要gpt的废话
                if let startRange = retJson.range(of: "{"), let endRange = retJson.range(of: "}", options: .backwards) {
                    let startIndex = startRange.upperBound
                    let endIndex = endRange.lowerBound
                    retJson = "{\(String(retJson[startIndex..<endIndex]))}"
                }
                print(retJson)
                if let jsonData = retJson.data(using: .utf8), let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        withAnimation {
                            if let event_name = jsonObj["event_name"] as? String {
                                eventName = event_name
                            }
                            if let event_description = jsonObj["event_description"] as? String {
                                eventDescription = event_description
                            }
                            if let error = jsonObj["error"] as? String {
                                gptError = error
                            }
                            if let comment = jsonObj["comment"] as? String {
                                gptComment = comment
                            }
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if let dateString = jsonObj["event_time"] as? String, let date = dateFormatter.date(from: dateString) {
                                startDate = date
                            }
                            gptThinking = false
                        }
                        VibrateTwice()
                    }
                } else {
                    DispatchQueue.main.async {
                        gptThinking = false
                        globalVar.alertTitle = "GPT返回值错误!"
                        globalVar.alertContent = "无法解析GPT返回的请求，请尝试重试"
                        globalVar.showAlert = true
                    }
                    return
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    gptThinking = false
                    globalVar.alertTitle = "请求GPT接口出错"
                    globalVar.alertContent = "可能是网络问题，您可以尝试再试一次..."
                    globalVar.showAlert = true
                }
                return
            }
        }
    }
    var body: some View {
        Form {
            Section {
                if !useGpt {
                    Button("使用文字描述录入") {
                        withAnimation {
                            useGpt = true
                        }
                    }
                } else {
                    if !gptThinking {
                        if !gptComment.isEmpty {
                            Text(gptComment)
                                .foregroundColor(.green)
                        }
                        if !gptError.isEmpty {
                            Text(gptError)
                                .foregroundColor(.red)
                        }
                        if #available(iOS 16.0, *) {
                            TextField("示例：明天下午六点提醒我吃北理烤鹅", text: $gptAskContent, axis: .vertical)
                        } else {
                            TextField("示例：明天下午六点提醒我吃北理烤鹅", text: $gptAskContent)
                        }
                        Button("发送") {
                            AskGpt()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("请稍后...")
                            Spacer()
                        }
                    }
                    
                }
            } header: {
                Text("AI录入(实验性)")
            } footer: {
                Text("目前使用的gpt的api接口非常的慢，因此最终这个功能是否保留待定...")
            }
            Section("基本设置") {
                HStack {
                    Text("事件名称")
                    Spacer()
                    TextField("必填，输入事件名称", text: $eventName)
                }
                HStack {
                    Text("事件备注")
                    Spacer()
                    TextField("选填，输入事件备注(如地点、人数等)", text: $eventDescription)
                }
                HStack {
                    Text("事件链接")
                    Spacer()
                    TextField("选填，事件相关的链接", text: $eventUrl)
                }
                DatePicker(selection: $startDate, in: Date.now..., displayedComponents: [.date, .hourAndMinute]) {
                    Text("到期时间")
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
                if !eventUrl.isEmpty && URL(string: eventUrl) == nil {
                    globalVar.alertTitle = "事件链接不合法"
                    globalVar.alertContent = "请输入合法的事件链接"
                    globalVar.showAlert = true
                    return
                } else {
                    if !eventUrl.isEmpty && !eventUrl.hasPrefix("http://") && !eventUrl.hasPrefix("https://") {
                        eventUrl = "https://" + eventUrl
                    }
                }
                let eventName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
                let description = eventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                let courseId = withCourse ? selectCourseId : nil
                let courseName = withCourse ? GetCourseName(selectCourseId) : nil
                DataController.shared.addEventStored(isCustomEvent: true, event_name: eventName, event_description: description, lexue_id: nil, timestart: startDate, timeusermidnight: nil, mindaytimestamp: .now, course_id: courseId, course_name: courseName, color: color, action_url: eventUrl, event_type: eventType, instance: nil, url: nil, context: managedObjContext)
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
