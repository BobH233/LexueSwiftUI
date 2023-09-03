//
//  ContentView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MessageListView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("消息")
                }
                .tag(0)
            CourseListView()
                .tabItem {
                    Image(systemName: "graduationcap.fill")
                    Text("课程")
                }
                .tag(1)
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
