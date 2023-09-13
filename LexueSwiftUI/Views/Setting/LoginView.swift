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
    @State var loginContext: LoginContext = LoginContext()
    @State var needCaptcha: Bool = false
    @State private var imageCaptchaData: Data? = nil
    @State private var loginBtnDisabled = true
    @FocusState private var focusedOnPassword
    
    @State private var showErrorTipsTitle: String = ""
    @State private var showErrorTipsContent: String = ""
    @State private var showError = false
    
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
            loginBtnDisabled = false
            globalVar.isLoading = false
            switch result {
            case .success(let data):
                print(data)
                settings.savedUsername = username
                settings.savedPassword = password
                settings.loginnedContext = data
                globalVar.isLogin = true
                dismiss()
            case .failure(let error):
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
                }
            }
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
                doLogin()
            } label: {
                Text("登录")
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
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
            doLogin()
        }
        .onAppear {
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
        .alert(isPresented: $showError) {
            Alert(title: Text(showErrorTipsTitle), message: Text(showErrorTipsContent), dismissButton: .default(Text("确定")))
        }
        .navigationTitle("登录北理账号")
    }
}

#Preview {
    LoginView()
}
