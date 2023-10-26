//
//  SettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import ImageViewer
import CloudKitSyncMonitor

struct SettingView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var settings = SettingStorage.shared
    @State var showImageViewer = false
    @State var avatar_image = Image("default_avatar")
    @State var openViewScoreNavigation = false
    @State var openExamInfoNavigation = false
    @State private var colorSchemeIndex = SettingStorage.shared.preferColorScheme
    var colorSchemeText = ["黑暗模式", "明亮模式", "跟随系统"]
    
    @ObservedObject var syncMonitor = SyncMonitor.shared
    
    var body: some View {
        NavigationView {
            Form {
                // avatar group
                if globalVar.isLogin {
                    Section(header: Text("北理账号")) {
                        HStack{
                            Spacer()
                                .foregroundColor(.blue)
                            VStack {
                                Image(uiImage: globalVar.userAvatarUIImage!)
                                    .resizable()
                                    .frame(width:100, height: 100, alignment: .center)
                                    .shadow(radius: 26)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                    .padding(.top, 10)
                                    .onTapGesture {
                                        avatar_image = Image(uiImage: globalVar.userAvatarUIImage!)
                                        showImageViewer.toggle()
                                    }
                                
                                Text(globalVar.cur_user_info.fullName)
                                    .font(.title)
                                    .bold()
                                    .padding(.top, 15)
                                    .padding(.bottom, 1)
                                Text(globalVar.cur_user_info.stuId)
                                    .bold()
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 10)
                            }
                            Spacer()
                        }
                    }
                    Section("iCloud同步") {
                        HStack {
                            Image(systemName: syncMonitor.syncStateSummary.symbolName)
                                .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                            if syncMonitor.syncError {
                                if let _ = syncMonitor.setupError {
                                    Text("iCloud初始化失败")
                                }
                                if let _ = syncMonitor.importError {
                                    Text("iCloud导入失败")
                                }
                                if let _ = syncMonitor.exportError {
                                    Text("iCloud上传失败")
                                }
                            } else if syncMonitor.notSyncing {
                                Text("iCloud未同步，请检查设置")
                            } else if syncMonitor.syncStateSummary == .inProgress {
                                Text("iCloud正在同步")
                            } else if syncMonitor.syncStateSummary == .accountNotAvailable {
                                Text("请登录iCloud账号以使用同步")
                            } else if syncMonitor.syncStateSummary == .noNetwork {
                                Text("网络连接后开始同步")
                            } else if syncMonitor.syncStateSummary == .notStarted {
                                Text("iCloud未开始同步")
                            } else if syncMonitor.syncStateSummary == .succeeded {
                                Text("iCloud同步成功")
                            } else {
                                Text("未知的iCloud状态")
                            }
                        }
                    }
                }
                if globalVar.isLogin {
                    Section {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                            HStack {
                                Spacer()
                                Text("查课程成绩")
                                    .bold()
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                Spacer()
                            }
                            NavigationLink("", destination: ViewScoreView(), isActive: $openViewScoreNavigation)
                                .isDetailLink(false)
                                .hidden()
                        }
                        .onTapGesture {
                            VibrateOnce()
                            openViewScoreNavigation = true
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    Section {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                            HStack {
                                Spacer()
                                Text("看考试安排")
                                    .bold()
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                Spacer()
                            }
                            NavigationLink("", destination: ExamInfoView(), isActive: $openExamInfoNavigation)
                                .isDetailLink(false)
                                .hidden()
                        }
                        .onTapGesture {
                            VibrateOnce()
                            openExamInfoNavigation = true
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                if globalVar.debugMode || globalVar.DEBUG_BUILD {
                    Section(header: Text("Debug")) {
                        Toggle(isOn: $globalVar.isLogin) {
                            Text("isLogin")
                        }
                        NavigationLink("DebugView") {
                            DebugDataView()
                        }
                    }
                }
                if globalVar.isLogin {
                    NavigationLink(destination: ProfileView(), label: {
                        HStack{
                            Image(systemName: "person.crop.rectangle.fill")
                                .foregroundColor(.blue)
                            Text("个人资料")
                                .foregroundColor(.blue)
                        }
                    })
                    Button(action: {
                        print("exit login")
                        UMAnalyticsSwift.event(eventId: "unlogin", attributes: ["username": globalVar.cur_user_info.userId])
                        settings.loginnedContext = BITLogin.LoginSuccessContext()
                        globalVar.cur_lexue_context = LexueAPI.LexueContext()
                        SettingStorage.shared.set_widget_shared_LexueContext(LexueAPI.LexueContext())
                        withAnimation {
                            globalVar.isLogin = false
                        }
                    }) {
                        HStack{
                            Image(systemName: "delete.right.fill")
                                .foregroundColor(.red)
                            Text("退出登录")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    NavigationLink(destination: LoginView(), label: {
                        Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                            .foregroundColor(.blue)
                        Text("登录北理账号")
                    })
                }
                if globalVar.isLogin {
                    Section(header: Text("应用设置")) {
                        HStack{
                            NavigationLink(destination: {
                                DataProviderSettingView()
                            }, label: {
                                Text("消息源设定")
                            })
                            .isDetailLink(false)
                        }
                        HStack{
                            Picker(selection: $colorSchemeIndex, label: Text("外观")) {
                                ForEach(0 ..< colorSchemeText.count) {
                                    Text(self.colorSchemeText[$0])
                                }
                            }
                        }
                        .onChange(of: colorSchemeIndex) { newValue in
                            SettingStorage.shared.preferColorScheme = newValue
                        }
                    }
                }
                Section(header: Text("关于")) {
                    NavigationLink(destination: Feedback(), label: {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.blue)
                        Text("反馈意见")
                    })
                    .isDetailLink(false)
                    NavigationLink(destination: PrivacyStatement(), label: {
                        Image(systemName: "lock.circle")
                            .foregroundColor(.blue)
                        Text("应用隐私声明")
                    })
                    .isDetailLink(false)
                    NavigationLink(destination: AboutView(), label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("关于")
                    })
                    .isDetailLink(false)
                }
                if globalVar.DEBUG_BUILD {
                    Text("DEBUG_BUILD_VERSION")
                    Text("channel: \(globalVar.CURRENT_CHANNEL)")
                }
                
            }
            .frame(maxWidth: 500)
            .navigationViewStyle(.stack)
            .overlay(ImageViewer(image: self.$avatar_image, viewerShown: self.$showImageViewer))
            .navigationTitle("设置")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
