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
    @State var captcha: String = ""
    @State var loginContext: BITLogin.LoginContext = BITLogin.LoginContext()
    @State var needCaptcha: Bool = false
    @State private var imageCaptchaData: Data? = nil
    @State private var loginBtnDisabled = true
    @FocusState private var focusedOnPassword
    
    @State private var showErrorTipsTitle: String = ""
    @State private var showErrorTipsContent: String = ""
    @State private var showError = false
    
    @State private var showTipsAlert = false
    
    func refreshCaptcha() {
        BITLogin.shared.get_captcha_data(context: loginContext) { result in
            switch result {
            case .success(let data):
                imageCaptchaData = data
            case .failure(_):
                showErrorTipsTitle = "网络错误(获取验证码图像失败)"
                showErrorTipsContent = "请检查你的网络环境，然后重试"
                showError = true
            }
        }
    }
    
    func checkNeedCaptcha() {
        BITLogin.shared.check_need_captcha(context: loginContext, username: username) { result in
            switch result {
            case .success(let data):
                needCaptcha = data
            case .failure(_):
                showErrorTipsTitle = "网络错误(检查验证码失败)"
                showErrorTipsContent = "请检查你的网络环境，然后重试"
                showError = true
            }
        }
    }
    
    func doLogin() {
        loginBtnDisabled = true
        globalVar.LoadingText = "登录中"
        globalVar.isLoading = true
        BITLogin.shared.do_login(context: loginContext, username: username, password: password, captcha: captcha) { result in
            switch result {
            case .success(let data):
                print(data)
                DispatchQueue.main.async {
                    settings.savedUsername = username
                    settings.savedPassword = password
                }
                UMAnalyticsSwift.event(eventId: "login", attributes: ["username": username])
                settings.loginnedContext = data
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
                                // 避免一下子出现一堆的事件...
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
                        showErrorTipsTitle = "网络错误(乐学登录失败)"
                        showErrorTipsContent = "请检查你的网络环境，然后重试"
                        showError = true
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
                case .stopAccount:
                    refreshCaptcha()
                    showErrorTipsTitle = "账号被冻结(登录失败)"
                    showErrorTipsContent = "可能尝试错误密码过多次，请稍等15分钟再试"
                    showError = true
                case .unknowError:
                    showErrorTipsTitle = "未知错误(登录失败)"
                    showErrorTipsContent = "请检查账号密码以及网络环境"
                    showError = true
                case .wrongCaptcha:
                    refreshCaptcha()
                    showErrorTipsTitle = "验证码错误(登录失败)"
                    showErrorTipsContent = "请重新输入验证码"
                    showError = true
                case .wrongPassword:
                    if needCaptcha {
                        refreshCaptcha()
                    } else {
                        checkNeedCaptcha()
                    }
                    showErrorTipsTitle = "账号或密码错误(登录失败)"
                    showErrorTipsContent = "请检查账号和密码是否错误"
                    showError = true
                case .cryptoError:
                    showErrorTipsTitle = "客户端错误(登录失败)"
                    showErrorTipsContent = "加密过程出现错误，请稍后重试"
                    showError = true
                }
            }
        }
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
                .padding(.bottom, needCaptcha ? 20 : 30)
            if needCaptcha {
                HStack {
                    TextField("验证码", text: $captcha)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5.0)
                        .keyboardType(.default)
                    if let data = imageCaptchaData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .onTapGesture {
                                refreshCaptcha()
                            }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .onAppear {
                    refreshCaptcha()
                }
            }
            
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
            // 确保已经获取到了消息
            UIApplication.shared.registerForRemoteNotifications()
            username = settings.savedUsername
            password = settings.savedPassword
            BITLogin.shared.init_login_param { result in
                switch result {
                case .success(let context):
                    loginContext = context
                    loginBtnDisabled = false
                case .failure(_):
                    showErrorTipsTitle = "网络错误(初始化登录参数失败)"
                    showErrorTipsContent = "请检查你的网络环境，然后重试"
                    showError = true
                }
            }
        }
        .onChange(of: focusedOnPassword) { newVal in
            if !newVal && !username.isEmpty {
                // 开始看是否需要验证码
                print("check captcha")
                checkNeedCaptcha()
            }
        }
        .navigationTitle("登录北理账号")
    }
}

#Preview {
    LoginView()
}
