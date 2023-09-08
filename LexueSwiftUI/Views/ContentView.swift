//
//  ContentView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 0
    var body: some View {
        TabView {
            MessageListView(tabSelection: $tabSelection)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("消息")
                }
                .tag(0)
            CourseListView(debug_use_lazy_v_stack: true)
                .tabItem {
                    Image(systemName: "graduationcap.fill")
                    Text("课程")
                }
                .tag(1)
            CourseListView(debug_use_lazy_v_stack: false)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("最近事件")
                }
                .tag(2)
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
