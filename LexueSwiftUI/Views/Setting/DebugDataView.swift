//
//  DebugDataView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import SwiftUI

struct DebugDataView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    
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
    
    @State var isPresentAlert = false
    var body: some View {
        Form {
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

