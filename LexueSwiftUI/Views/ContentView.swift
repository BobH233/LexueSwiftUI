//
//  ContentView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 0
    @ObservedObject var globalVar = GlobalVariables.shared
    var body: some View {
        TabView(selection: $tabSelection) {
            MessageListView(tabSelection: $tabSelection)
                .tag(1)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("消息")
                }
            CourseListView(debug_use_lazy_v_stack: true)
                .tag(2)
                .tabItem {
                    Image(systemName: "graduationcap.fill")
                    Text("课程")
                }
            CourseListView(debug_use_lazy_v_stack: false)
                .tag(3)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("最近事件")
                }
            SettingView()
                .tag(4)
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
        }
        .overlay {
            if globalVar.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                            .opacity(0.9)
                            .frame(width: 100, height: 100)
                            .shadow(radius: 10)
                            .overlay {
                                VStack {
                                    ProgressView()
                                        .padding(.bottom, 10)
                                    Text(globalVar.LoadingText)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
