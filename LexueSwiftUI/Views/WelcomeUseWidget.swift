//
//  WelcomeUseWidget.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/7.
//

import SwiftUI

struct WelcomeUseWidget: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text("更及时刷新获取消息")
                            .font(.largeTitle)
                        Text("推荐使用乐学助手小组件")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                ZStack {
                    Image("widget_large_preview")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 23))
                        .padding(.horizontal, 40)
                        .shadow(radius: 10)
                        .offset(CGSize(width: 20.0, height: 10.0))
                    Image("widget_medium_preview")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 23))
                        .padding(.horizontal, 40)
                        .shadow(radius: 10)
                        .offset(CGSize(width: -20.0, height: 80.0))
                    Image("widget_small_preview")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .padding(.horizontal, 120)
                        .shadow(radius: 10)
                        .offset(CGSize(width: 100.0, height: 130.0))
                        
                }
                .padding(.top, 40)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("我知道了")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .padding(.bottom, 20)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 30)
                
            }
            .frame(maxWidth: 400)
            Spacer()
        }
        
    }
}

#Preview {
    WelcomeUseWidget()
}
