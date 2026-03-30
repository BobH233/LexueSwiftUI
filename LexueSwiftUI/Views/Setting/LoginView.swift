//
//  LoginView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/12.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var settings = SettingStorage.shared
    @ObservedObject var globalVar = GlobalVariables.shared
    
    @Environment(\.dismiss) var dismiss
    
    @State var username: String = ""
    @State var password: String = ""
    // [旧版表单登录] 验证码相关状态，REST API 方式不再需要
    // @State var captcha: String = ""
    // @State var loginContext: BITLogin.LoginContext = BITLogin.LoginContext()
    // @State var needCaptcha: Bool = false
    // @State private var imageCaptchaData: Data? = nil
    @State private var loginBtnDisabled = false
    @FocusState private var focusedOnPassword
    
    @State private var showErrorTipsTitle: String = ""
    @State private var showErrorTipsContent: String = ""
    @State private var showError = false
    
    @State private var showTipsAlert = false
    
    // [旧版表单登录] 验证码相关方法，REST API 方式不再需要
    // func refreshCaptcha() {
    //     BITLogin.shared.get_captcha_data(context: loginContext) { result in
    //         switch result {
    //         case .success(let data):
    //             imageCaptchaData = data
    //         case .failure(_):
    //             showErrorTipsTitle = "网络错误(获取验证码图像失败)"
    //             showErrorTipsContent = "请检查你的网络环境，然后重试"
    //             showError = true
    //         }
    //     }
    // }
    //
    // func checkNeedCaptcha() {
    //     BITLogin.shared.check_need_captcha(context: loginContext, username: username) { result in
    //         switch result {
    //         case .success(let data):
    //             needCaptcha = data
    //         case .failure(_):
    //             showErrorTipsTitle = "网络错误(检查验证码失败)"
    //             showErrorTipsContent = "请检查你的网络环境，然后重试"
    //             showError = true
    //         }
    //     }
    // }
    
    func doLogin() {
        loginBtnDisabled = true
        globalVar.LoadingText = "登录中"
        globalVar.isLoading = true
        // 使用 CAS REST API 登录（绕过验证码和短信验证）
        BITLogin.shared.do_login_rest(username: username, password: password) { result in
            switch result {
            case .success(let data):
                print(data)
                DispatchQueue.main.async {
                    settings.savedUsername = username
                    settings.savedPassword = password
                }
                UMAnalyticsSwift.event(eventId: "login", attributes: ["username": username])
                settings.loginnedContext = data
                if !GlobalVariables.shared.is_postgraduate(specifyId: username) {
                    LexueAPI.shared.GetLexueContext(SettingStorage.shared.loginnedContext) { result in
                        switch result {
                        case .success(let context):
                            globalVar.cur_lexue_context = context
                            AppStatusManager.shared.action_after_get_lexue_context(context)
                            Task {
                                let ret = await CoreLogicManager.shared.RefreshSelfUserInfo()
                                DispatchQueue.main.async {
                                    globalVar.isLoading = false
                                    loginBtnDisabled = false
                                    settings.lastLoginUsername = username
                                    settings.HaoBITFirstFetch = true
                                    dismiss()
                                }
                                if ret {
                                    DispatchQueue.main.async {
                                        globalVar.isLogin = true
                                    }
                                }
                            }
                            
                        case .failure(_):
                            globalVar.isLoading = false
                            loginBtnDisabled = false
                            showErrorTipsTitle = "网络错误(乐学登录失败)"
                            showErrorTipsContent = "请检查你的网络环境，然后重试"
                            showError = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        GlobalVariables.shared.alertTitle = "研究生功能受限"
                        GlobalVariables.shared.alertContent = "检测到你是研究生，已经无法访问乐学平台的服务，本App的全部乐学相关功能将被禁用。你仍然可以使用课程表App相关功能。"
                        GlobalVariables.shared.showAlert = true
                        globalVar.isLoading = false
                        loginBtnDisabled = false
                        settings.lastLoginUsername = username
                        settings.HaoBITFirstFetch = true
                        dismiss()
                        globalVar.isLogin = true
                    }
                }
            case .failure(let error):
                globalVar.isLoading = false
                loginBtnDisabled = false
                switch error {
                case .networkError:
                    showErrorTipsTitle = "网络错误(登录失败)"
                    showErrorTipsContent = "请检查你的网络环境，然后重试"
                    showError = true
                case .wrongPassword:
                    showErrorTipsTitle = "账号或密码错误(登录失败)"
                    showErrorTipsContent = "请检查账号和密码是否错误"
                    showError = true
                default:
                    showErrorTipsTitle = "未知错误(登录失败)"
                    showErrorTipsContent = "请检查账号密码以及网络环境"
                    showError = true
                }
            }
        }
        // [旧版表单登录] 原始登录方式（需要 init_login_param + 验证码 + AES 加密）
        // BITLogin.shared.do_login(context: loginContext, username: username, password: password, captcha: captcha) { result in ... }
    }
    
    func doLoginPreVerify() {
        if settings.lastLoginUsername == "" || settings.lastLoginUsername == username {
            doLogin()
        } else {
            showTipsAlert = true
        }
    }
    
    var body: some View {
        VStack {
            TextField("请输入学号", text: $username)
                .focused($focusedOnPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .keyboardType(.default)
                .padding(.top, 30)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                .alert(isPresented: $showError) {
                    Alert(title: Text(showErrorTipsTitle), message: Text(showErrorTipsContent), dismissButton: .default(Text("确定")))
                }
            SecureField("请输入密码", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .keyboardType(.default)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            // [旧版表单登录] 验证码 UI，REST API 方式不再需要
            // if needCaptcha {
            //     HStack {
            //         TextField("验证码", text: $captcha)
            //             .padding()
            //             .background(Color(.systemGray6))
            //             .cornerRadius(5.0)
            //             .keyboardType(.default)
            //         if let data = imageCaptchaData, let uiImage = UIImage(data: data) {
            //             Image(uiImage: uiImage)
            //                 .onTapGesture {
            //                     refreshCaptcha()
            //                 }
            //         }
            //     }
            //     .padding(.horizontal, 30)
            //     .padding(.bottom, 30)
            //     .onAppear {
            //         refreshCaptcha()
            //     }
            // }
            
            Button {
                doLoginPreVerify()
            } label: {
                Text("登录")
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .alert(isPresented: $showTipsAlert) {
                Alert(title: Text("温馨提示"), message: Text("我们建议您不要在同一个手机上登录多个北理账号，否则可能造成数据冲突，重复，错乱问题，真的要继续登录吗？"), primaryButton: .destructive(Text("确认"), action: {
                    doLogin()
                }), secondaryButton: .cancel(Text("取消")))
            }
            .disabled(loginBtnDisabled)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            Spacer()
        }
        .onSubmit(of: .text) {
            if loginBtnDisabled {
                return
            }
            doLoginPreVerify()
        }
        .onAppear {
            UIApplication.shared.registerForRemoteNotifications()
            username = settings.savedUsername
            password = settings.savedPassword
            // [旧版表单登录] REST API 方式不再需要初始化登录参数
            // BITLogin.shared.init_login_param { result in
            //     switch result {
            //     case .success(let context):
            //         loginContext = context
            //         loginBtnDisabled = false
            //     case .failure(_):
            //         showErrorTipsTitle = "网络错误(初始化登录参数失败)"
            //         showErrorTipsContent = "请检查你的网络环境，然后重试"
            //         showError = true
            //     }
            // }
        }
        .navigationTitle("登录北理账号")
    }
}

#Preview {
    LoginView()
}
