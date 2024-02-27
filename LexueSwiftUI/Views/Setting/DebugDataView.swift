//
//  DebugDataView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import SwiftUI
import EventKit

struct DebugDataView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @ObservedObject var globalVar = GlobalVariables.shared
    
    @State var senderUid: String = ""
    var msgtype = [MessageBodyType.text, MessageBodyType.link, MessageBodyType.image]
    var msgtypeStr = ["text", "image", "link"]
    @State var setMsgType: Int = 0
    @State var text_data: String = ""
    @State var image_data: String = ""
    @State var link_data: String = ""
    @State var link_title: String = ""
    @State var date: Date = Date()
    
    @State var contactUid: String = ""
    @State var originName: String = ""
    @State var pinned: Bool = false
    @State var silent: Bool = false
    
    @State var password: String = ""
    @State var salt: String = "VWlZISuTMg4yd4aQ"
    @State var encryptPasswd: String = ""
    
    
    @State var loginContext: BITLogin.LoginContext = BITLogin.LoginContext()
    @State var username1: String = ""
    @State var password1: String = ""
    @State var captcha1: String = ""
    @State var init_login_failed: Bool = false
    @State var need_captcha: Bool = false
    @State private var imageCaptchaData: Data? = nil
    @State private var loginnedContext: BITLogin.LoginSuccessContext = BITLogin.LoginSuccessContext()
    
    @State var userId: String = ""
    
    @State var JXZX_context: JXZXehall.JXZXContext = JXZXehall.JXZXContext()
    
    @State var isPresentAlert = false
    
    @State var eventStore = EKEventStore()
    
    @State var latStr: String = "39.738763"
    @State var lonStr: String = "116.178278"
    
    var body: some View {
        Form {
            Section("Map") {
                TextField("latStr", text: $latStr)
                TextField("lonStr", text: $lonStr)
                Button("打开地图") {
                    
                    SchoolMapManager.shared.OpenMapAppWithLocation(latitude: Double(latStr)!, longitude: Double(lonStr)!, regionDistance: 1000, name: "北理大专")
                }
                Button("dump_json") {
                    let encoder = JSONEncoder()

                    // 设置编码选项（例如，漂亮打印）
                    encoder.outputFormatting = .prettyPrinted

                    // 尝试编码default_school_locations到JSON
                    do {
                        let jsonData = try encoder.encode(SchoolMapManager.shared.default_school_locations)
                        
                        // 将JSON数据转换为String以便打印或其他用途
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print(jsonString)
                        }
                    } catch {
                        print("编码错误: \(error)")
                    }
                }
            }
            Section("Schedule") {
                Button("添加或覆盖日历列表") {
                    Task {
                        let res = await iOSCalendarManager.shared.AddNewCalendar(calendarName: "📅 我的日历表", calendarColor: .red, rewriteExist: true)
                        if(res != nil) {
                            DispatchQueue.main.async {
                                GlobalVariables.shared.alertTitle = "Success"
                                GlobalVariables.shared.alertContent = "Success"
                                GlobalVariables.shared.showAlert = true
                            }
                            print("成功")
                        } else {
                            DispatchQueue.main.async {
                                GlobalVariables.shared.alertTitle = "Failed"
                                GlobalVariables.shared.alertContent = "Failed"
                                GlobalVariables.shared.showAlert = true
                            }
                            print("失败")
                        }
                    }
                }
                Button("添加日历列表") {
                    eventStore.requestAccess(to: .event) { granted, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        if granted {
                            print("granted!")
                            let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
                            newCalendar.title = "北理工课程表"
                            newCalendar.cgColor = UIColor.systemBlue.cgColor
                            print(eventStore.sources)
                            // 选择源
                            if let iCloudSource = eventStore.sources.first(where: { $0.sourceType == .calDAV && $0.title == "iCloud" }) {
                                newCalendar.source = iCloudSource
                            } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
                                newCalendar.source = localSource
                            } else {
                                print("未找到合适的源")
                                return
                            }
                            do {
                                try eventStore.saveCalendar(newCalendar, commit: true)
                                print("新日历创建成功！")
                            } catch {
                                print("创建日历时发生错误: \(error)")
                            }
                        }
                    }
                }
            }
            Section("Backend") {
                Button("GetScheduleSectionInfo") {
                    Task {
                        let res = await LexueHelperBackend.shared.GetScheduleSectionInfo()
                        print(res)
                    }
                }
                Button("UploadDeviceToken") {
                    Task {
                        let res = await LexueHelperBackend.shared.RegisterDeviceTokenForServer(userId: "12345", deviceToken: "23333")
                    }
                }
                Button("FetchNotification") {
                    Task {
                        let res = await LexueHelperBackend.shared.FetchAppNotifications()
                        print(res)
                    }
                }
                Button("ISAdmin") {
                    Task {
                        let res = await LexueHelperBackend.shared.GetIsAdmin(userId: "123")
                        print(res)
                    }
                }
            }
            Section("JXZX") {
                Button("GetTickLoginRes") {
                    Task {
                        let location1 = await JXZXehall.shared.GetUrlRetHead(url: "https://jxzxehall.bit.edu.cn/appShow?appId=5959167891382285")["Location"]
                        print(location1)
                    }
                }
                Button("get_pc_Context") {
                    Task {
                        let result = await JXZXehall.shared.GetJXZXwdkbbyContext(loginnedContext: SettingStorage.shared.loginnedContext)
                        switch result {
                        case .success(let context):
                            JXZX_context = context
                            print(context)
                        case .failure(_):
                            print("failed to get jxzx context!")
                        }
                    }
                }
                Button("GetSemesterFirstDay") {
                    Task {
                        let res = await JXZXehall.shared.GetSemesterStartDate(context: JXZX_context, semesterId: "2023-2024-2")
                        print(res)
                    }
                }
                Button("get_mobile_Context") {
                    Task {
                        let result = await JXZXehall.shared.GetJXZXMobileContext(loginnedContext: SettingStorage.shared.loginnedContext)
                        switch result {
                        case .success(let context):
                            JXZX_context = context
                            print(context)
                        case .failure(_):
                            print("failed to get jxzx context!")
                        }
                    }
                }
                Button("get_schedule_courses") {
                    Task {
                        let result = await JXZXehall.shared.GetSemesterScheduleCourses(context: JXZX_context, semesterId: "2023-2024-2")
                        print(result)
                    }
                }
                Button("get_current_semester") {
                    Task {
                        let result = await JXZXehall.shared.GetCurrentSemesterInfo(context: JXZX_context)
                        print(result)
                    }
                }
                Button("get_all_semester") {
                    Task {
                        let result = await JXZXehall.shared.GetAllSemesterInfo(context: JXZX_context)
                        print(result)
                    }
                }
                Button("get_unscheduled_exam") {
                    Task {
                        let result = await JXZXehall.shared.GetUnscheduledExam(context: JXZX_context, semesterId: "2023-2024-1")
                        print(result)
                    }
                }
                Button("get_arranged_exam") {
                    Task {
                        let result = await JXZXehall.shared.GetArrangedExam(context: JXZX_context, semesterId: "2022-2023-2")
                        print(result)
                    }
                }
            }
            Section("Webvpn") {
                Button("loginWebvpn_queryScore") {
                    Task {
                        let result = await Webvpn.shared.GetWebvpnContext(username: SettingStorage.shared.savedUsername, password: SettingStorage.shared.savedPassword)
                        print(result)
                        switch result {
                        case .success(let context):
                            let res2 = await Webvpn.shared.QueryScoreInfo(webvpn_context: context)
                            print(res2)
                        case .failure(_):
                            print("无法登录webvpn")
                        }
                    }
                }
            }
            Section("GPT") {
                Button("Ask") {
                    Task {
                        let result = await GPTApiFree.shared.RequestGPT(param: GPTApiFree.GPTRequestParam(messages: [
                            GPTApiFree.GPTMessage(role: "system", content: "你现在是一个json格式文本生成器，输出json供程序去解析，用户给你的指令是设置一个提醒事项。你输出的json对象文本需要包含一下几个内容：（1）提醒事项名称（event_name），这个可以你根据用户的指令自行决定（2）提醒事项的发生时间(event_time)，这是一个文本，格式为“年-月-日 时:分:秒”，我会告诉你现在的时间，然后你自己根据用户的指令决定输出的时间文本（3）提醒事项的备注（event_description）这个你根据用户的指令自行决定，比如事件发生的地点，参加人等等（4）错误信息（error），假如用户输入了其他无关的东西，或者给你的指令你无法理解，请你在这里以字符串输出错误信息，如果没有错误，这里请输出null。（5）给用户说的话（comment），这里输出你为顾客安排了事件过后，想对顾客说的话，可以自由发挥，如果没有可以保持null。"),
                            GPTApiFree.GPTMessage(role: "user", content: "现在的时间是2023年10月7日20：53分星期六，用户给你的指令是：“提醒我明天晚上吃牛肉面”，直接输出json内容，不要有多余的话和补充")
                        ]))
                        switch result {
                        case .success(let success_res):
                            print(success_res)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            Section("HaoBIT") {
                Button("GetNotices") {
                    Task {
                        let res = await HaoBIT.shared.GetNotices()
                        print(res)
                    }
                }
            }
            Section("timeout") {
                Button("Normal") {
                    Task(timeout: 2) {
                        do {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            print("Test after 1s")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                Button("Timtout") {
                    Task(timeout: 2) {
                        do {
                            try await Task.sleep(nanoseconds: 5_000_000_000)
                            print("Test after 5s")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                Button("Request") {
                    Task(timeout: 2) {
                        do {
                            try await CoreLogicManager.shared.UpdateEventList()
                            print("Request finished")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            Section("push message") {
                TextField("ContactUid", text: $senderUid)
                TextField("originName", text: $originName)
                Button("send") {
                    var bodyy = MessageBodyItem(type: .text)
                    bodyy.text_data = "测试你好你好！"
                    MessageManager.shared.PushMessageWithContactCreation(senderUid: senderUid, contactOriginNameIfMissing: originName, contactTypeIfMissing: .course, msgBody: bodyy, date: Date(), context: managedObjContext)
                }
            }
            Section("UMeng") {
                Button("event1") {
                    UMAnalyticsSwift.event(eventId: "test1", label: "12345")
                }
                Button("event2") {
                    UMAnalyticsSwift.event(eventId: "login", label: "12345")
                }
                Button("event3") {
                    UMAnalyticsSwift.event(eventId: "login", attributes: ["attr": "lalala", "really": "true"])
                }
            }
            Section("Notification") {
                Button("GuardPermission") {
                    LocalNotificationManager.shared.GuardNotificationPermission()
                }
                Button("Push") {
                    LocalNotificationManager.shared.PushNotification(title: "title_test", body: "body_test", userInfo: ["userInfo1234":"1234"], image: globalVar.userAvatarUIImage, interval: 0.01)
                }
            }
            Section("LexueAPI") {
                Button("event_DB") {
                    let events = DataController.shared.queryAllEventStored(isDeleted: false, context: DataController.shared.container.viewContext)
                    for event in events {
                        print(event.id!.uuidString)
                    }
                }
                Button("GetNotification") {
                    Task {
                        let res = await LexueAPI.shared.GetPopupNotifications(globalVar.cur_lexue_context, sesskey: globalVar.cur_lexue_sessKey, selfUserId: GlobalVariables.shared.cur_user_info.userId)
                        switch res {
                        case .success(let ress):
                            print(ress)
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
                Button("GetEventsMonth") {
                    Task {
                        let res = try? await LexueAPI.shared.GetEventsByMonth(globalVar.cur_lexue_context, sesskey: globalVar.cur_lexue_sessKey, year: "2023", month: "10")
                        switch res! {
                        case .success(let ress):
                            print(ress)
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
                Button("GetEventsDay") {
                    Task {
                        let res = try? await LexueAPI.shared.GetEventsByDay(globalVar.cur_lexue_context, sesskey: globalVar.cur_lexue_sessKey, year: "2023", month: "10", day: "1")
                        switch res! {
                        case .success(let ress):
                            print(ress)
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
                Button("GetCourseMembers") {
                    Task {
                        let res = await LexueAPI.shared.GetCourseMembersInfo(globalVar.cur_lexue_context, sesskey: globalVar.cur_lexue_sessKey, courseId: "12698")
                        switch res {
                        case .success(let ress):
                            for a in ress {
                                print(a.name)
                            }
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
                Button("GetCourseSection") {
                    Task {
                        let res = await LexueAPI.shared.GetCourseSections(globalVar.cur_lexue_context, courseId: "13882")
                        switch res {
                        case .success(let ress):
                            print(ress)
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
                Button("serviceCall") {
                    Task {
                        await LexueAPI.shared.UniversalServiceCall(globalVar.cur_lexue_context, sesskey: globalVar.cur_lexue_sessKey, methodName: "core_course_get_enrolled_courses_by_timeline_classification", args: [
                            "offset": 0,
                            "limit": 0,
                            "classification": "all",
                            "sort": "fullname",
                            "customfieldname": "",
                            "customfieldvalue": ""
                        ])
                    }
                }
                Button("get_course_list") {
                    Task {
                        let res = await LexueAPI.shared.GetAllCourseList(globalVar.cur_lexue_context, sesskey: globalVar.cur_lexue_sessKey)
                        switch res {
                        case .success(let data):
                            DispatchQueue.main.async {
                                globalVar.courseList = data
                            }
                        case .failure(_):
                            print("获取失败")
                        }
                    }
                }
                Button("get_edit_profile_param") {
                    Task {
                        let res = await LexueAPI.shared.GetEditProfileParam(globalVar.cur_lexue_context)
                        print(res)
                    }
                }
                Button("update_profile_test") {
                    Task {
                        let res = await LexueAPI.shared.GetEditProfileParam(globalVar.cur_lexue_context)
                        switch res {
                        case .success(var profileParam):
                            profileParam.description_editor_text_ = "<div id=\"lexue_zhushou\">lalala</div>"
                            let res2 = await LexueAPI.shared.UpdateProfile(globalVar.cur_lexue_context, newProfile: profileParam)
                            switch res2 {
                            case .success(_):
                                print("edit ok!")
                            case .failure(_):
                                print("edit error!")
                            }
                            // print(res2)
                        case .failure(_):
                            print("获取profile 失败")
                        }
                    }
                }
                TextField("UserId", text: $userId)
                Button("get_profile_html") {
                    Task {
                        let result = await LexueAPI.shared.GetUserProfile(globalVar.cur_lexue_context, userId: userId)
                        switch result {
                        case .success(let html):
                            print(html)
                        case .failure(_):
                            print("获取 \(userId) profile 失败")
                        }
                    }
                }
            }
            Section("message data") {
                TextField("senderUid", text: $senderUid)
                Picker("MsgType", selection: $setMsgType) {
                    ForEach(msgtype, id: \.rawValue) {
                        Text(msgtypeStr[$0.rawValue])
                    }
                }
                TextField("text_data", text: $text_data)
                TextField("image_data", text: $image_data)
                TextField("link_data", text: $link_data)
                TextField("link_title", text: $link_title)
                DatePicker("date", selection: $date)
                HStack {
                    Spacer()
                    Button("Submit") {
                        MessageManager.shared.PushMessage(senderUid: senderUid, type: MessageBodyType(rawValue: setMsgType)!, text_data: text_data, image_data: image_data, link_data: link_data, link_title: link_title, date: date, context: managedObjContext)
                        isPresentAlert = true
                    }
                    Spacer()
                }
            }
            
            Section("contact data") {
                TextField("contactUid", text: $contactUid)
                TextField("originName", text: $originName)
                Toggle(isOn: $pinned, label: {
                    Text("pinned")
                })
                Toggle(isOn: $silent, label: {
                    Text("silent")
                })
                HStack {
                    Spacer()
                    Button("Submit") {
                        DataController.shared.addContactStored(contactUid: contactUid, originName: originName, pinned: pinned, silent: silent, unreadCount: 0, avatar_data: nil, context: managedObjContext)
                        isPresentAlert = true
                    }
                    Spacer()
                }
            }
            
            Section("BITLogin-1") {
                TextField("password", text: $password)
                TextField("salt", text: $salt)
                TextField("encryptedPasswd", text: $encryptPasswd)
                HStack {
                    Spacer()
                    Button("CalcEncrypted") {
                        encryptPasswd = BITLogin.shared.encryptPassword(pwd0: password, key: salt)
                    }
                    Spacer()
                }
            }
            
            Section("BITLogin-2") {
                Text("cookie: \(loginContext.cookies)")
                Text("execution: \(loginContext.execution)")
                    .lineLimit(2)
                Text("encryptSalt: \(loginContext.encryptSalt)")
                TextField("username", text: $username1)
                TextField("password", text: $password1)
                TextField("captcha", text: $captcha1)
                Text("needCaptcha: \(need_captcha ? "true" : "false")")
                Text("cookie_happy: \(loginnedContext.happyVoyagePersonal)")
                Text("cookie_CASTGC: \(loginnedContext.CASTGC)")
                VStack {
                    if let data = imageCaptchaData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("No captcha get")
                    }
                }
                HStack {
                    Spacer()
                    Button("init_login_param") {
                        BITLogin.shared.init_login_param { result in
                            switch result {
                            case .success(let context):
                                loginContext = context
                            case .failure(_):
                                init_login_failed = true
                            }
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("check_captcha") {
                        BITLogin.shared.check_need_captcha(context: loginContext, username: username1) { result in
                            switch result {
                            case .success(let data):
                                need_captcha = data
                            case .failure(_):
                                init_login_failed = true
                            }
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("get_captcha") {
                        BITLogin.shared.get_captcha_data(context: loginContext) { result in
                            switch result {
                            case .success(let data):
                                imageCaptchaData = data
                            case .failure(_):
                                init_login_failed = true
                            }
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("login") {
                        BITLogin.shared.do_login(context: loginContext, username: username1, password: password1, captcha: captcha1) { result in
                            switch result {
                            case .success(let data):
                                print(data)
                                loginnedContext = data
                            case .failure(let error):
                                print(error)
                                init_login_failed = true
                            }
                        }
                    }
                    Spacer()
                }
                
            }
        }
        .alert("保存成功", isPresented: $isPresentAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("操作失败", isPresented: $init_login_failed) {
            Button("OK", role: .cancel) { }
        }
    }
}

