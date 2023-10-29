//
//  ContentView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import MarkdownUI

struct ContentView: View {
    @State private var tabSelection = 0
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var appNotificationManager = AppNotificationsManager.shared
    var body: some View {
        TabView(selection: $tabSelection) {
            MessageListView(tabSelection: $tabSelection)
                .tag(1)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("消息")
                }
            CourseListView(tabSelection: $tabSelection)
                .tag(2)
                .tabItem {
                    Image(systemName: "graduationcap.fill")
                    Text("课程")
                }
            EventListView(tabSelection: $tabSelection)
                .tag(3)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("最近事件")
                }
            SettingView()
                .tag(4)
                .tabItem {
                    Image(systemName: "gear")
                    Text("个人中心")
                }
        }
        .onOpenURL { incomingURL in
            // debug
            if incomingURL.scheme == "um.65153a67b2f6fa00ba5c862a" {
                print("App was opened via URL: \(incomingURL)")
                MobClick.handle(incomingURL)
            } else if incomingURL.scheme == "lexuehelper" {
                guard let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
                    print("Invalid URL")
                    return
                }
                if let action = components.host, action == "enable_debug_mode" {
                    print("开启调试模式")
                    GlobalVariables.shared.debugMode = true
                    return
                }
                if let action = components.host, action == "disable_debug_mode" {
                    print("关闭调试模式")
                    GlobalVariables.shared.debugMode = false
                    return
                }
            }
        }
        .alert(isPresented: $globalVar.showAlert) {
            Alert(title: Text(globalVar.alertTitle), message: Text(globalVar.alertContent), dismissButton: .default(Text("确定")))
        }
        .sheet(isPresented: $globalVar.isShowWelcomUseWidgetSheet, content: {
            WelcomeUseWidget()
        })
        .sheet(isPresented: $globalVar.isShowPrivacyPolicySheet, content: {
            PrivacyPolicyView()
        })
        .sheet(isPresented: $appNotificationManager.showPopupSheet, content: {
            Form {
                if appNotificationManager.popupNotificationQueue.count > 0 {
                    Markdown(appNotificationManager.popupNotificationQueue.first!.markdownContent)
                    Button("已读") {
                        appNotificationManager.SetReadPopupId(id: appNotificationManager.popupNotificationQueue.first!.notificationId)
                    }
                }
            }
        })
        .overlay {
            if globalVar.isLoading {
                ZStack {
                    // 禁止触摸后面的view
                    Rectangle()
                        .opacity(0.1)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(.white)
                                .opacity(0.9)
                                .background(.ultraThickMaterial)
                                .frame(width: 100, height: 100)
                                .cornerRadius(10.0)
                                .shadow(radius: 20)
                                .overlay {
                                    VStack {
                                        ProgressView()
                                            .padding(.bottom, 10)
                                            .tint(.black)
                                        Text(globalVar.LoadingText)
                                            .foregroundColor(.black)
                                            .font(.system(size: 15))
                                    }
                                }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
