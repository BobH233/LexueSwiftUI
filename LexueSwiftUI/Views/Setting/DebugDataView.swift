//
//  DebugDataView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import SwiftUI

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
    
    @State var isPresentAlert = false
    var body: some View {
        Form {
            Section("UMeng") {
                Button("event1") {
                    UMAnalyticsSwift.event(eventId: "test1", label: "12345")
                }
                Button("event2") {
                    UMAnalyticsSwift.event(eventId: "login", label: "12345")
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

