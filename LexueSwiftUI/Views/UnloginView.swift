//
//  UnloginView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/25.
//

import SwiftUI

struct UnloginView: View {
    @Binding var tabSelection: Int
    var body: some View {
        VStack {
            Image(systemName: "person")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            Text("请登录使用乐学助手")
                .font(.title)
                .foregroundColor(.gray)
            Button("前往登录") {
                tabSelection = 4
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

