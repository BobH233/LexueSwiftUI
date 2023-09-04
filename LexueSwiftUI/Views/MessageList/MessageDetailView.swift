//
//  MessageDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import SwiftUI

private struct BubbleMessageView: View {
    @Environment(\.colorScheme) var sysColorScheme
    
    let BubbleColorDark = Color(#colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1607843137, alpha: 1))
    let BubbleColorLight = Color(#colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1))
    let message: String
    var body: some View {
        if sysColorScheme == .dark {
            ZStack(alignment: .bottomLeading) {
                Image("leftBubbleTail_dark")
                    .padding(EdgeInsets(top: 0, leading: -5, bottom: -2, trailing: 0))
                Text(message)
                    .foregroundColor(.white)
                    .frame(maxWidth: 200)
                    .padding(10)
                    .background(BubbleColorDark)
                    .cornerRadius(10)
                    .font(.system(size: 18))
            }
        } else {
            ZStack(alignment: .bottomLeading) {
                Image("leftBubbleTail_light")
                    .padding(EdgeInsets(top: 0, leading: -5, bottom: -2, trailing: 0))
                Text(message)
                    .foregroundColor(.black)
                    .frame(maxWidth: 200)
                    .padding(10)
                    .background(BubbleColorLight)
                    .cornerRadius(10)
                    .font(.system(size: 18))
            }
        }
    }
}

struct MessageDetailView: View {
    let contactUid: String
    
    var body: some View {
        NavigationView {
            BubbleMessageView(message: "你好啊, 这是多行文字啊啊啊啊啊啊啊啊啊")
        }
    }
}

#Preview {
    //BubbleMessageView(message: "你好啊, 这是多行文字啊啊啊啊啊啊啊啊啊")
    MessageDetailView(contactUid: "debug")
}
