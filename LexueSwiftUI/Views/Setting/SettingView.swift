//
//  SettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import ImageViewer


struct SettingView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var settings = SettingStorage.shared
    @State var showImageViewer = false
    @State var avatar_image = Image("default_avatar")
    
    @State private var colorSchemeIndex = SettingStorage.shared.preferColorScheme
    var colorSchemeText = ["黑暗模式", "明亮模式", "跟随系统"]
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
                    NavigationLink(destination: PrivacyStatement(), label: {
                        Image(systemName: "lock.circle")
                            .foregroundColor(.blue)
                        Text("应用隐私声明")
                    })
                    NavigationLink(destination: AboutView(), label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("关于")
                    })
                }
                if globalVar.DEBUG_BUILD {
                    Text("DEBUG_BUILD_VERSION")
                    Text("channel: \(globalVar.CURRENT_CHANNEL)")
                }
                
            }
            .overlay(ImageViewer(image: self.$avatar_image, viewerShown: self.$showImageViewer))
            .navigationTitle("设置")
        }
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
