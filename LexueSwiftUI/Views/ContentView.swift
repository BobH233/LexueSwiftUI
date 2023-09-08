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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
