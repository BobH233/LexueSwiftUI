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
            HStack {
                ZStack(alignment: .bottomLeading) {
                    Image("leftBubbleTail_light")
                        .padding(EdgeInsets(top: 0, leading: -5, bottom: -4, trailing: 0))
                    Text(message)
                        .foregroundColor(.black)
                        .frame(alignment: .leading)
                        .padding(10)
                        .background(BubbleColorLight)
                        .cornerRadius(10)
                        .font(.system(size: 18))
                }
                .padding(.leading, 20)
                .padding(.trailing, 50)
                Spacer()
            }
        }
    }
}

struct MessageDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let contactUid: String
    @State var contactName: String = "联系人啊"
    @State private var messages: [ContactMessage] = [
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "我是渣渣辉")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你是谁啊？？？？？？？？？？？？？？？？？")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")]),
        ContactMessage(sendDate: 0, senderUid: "debug", messageBody: [MessageBodyItem(type: .text, text_data: "你好啊啊")])
    ]
    var body: some View {
        
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        BubbleMessageView(message: message.messageBody[0].text_data!)
                    }
                }
                Button("dismiss") {
                    dismiss()
                }
                NavigationLink("lalala") {
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationTitle(contactName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // self.messages = GetContactsMessages(contactUid)
            }
        }
        
    }
}

#Preview {
//    ScrollView {
//        BubbleMessageView(message: "你好啊")
//        BubbleMessageView(message: "你好啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊aaa啊啊啊啊啊啊啊")
//        BubbleMessageView(message: "你好啊")
//    }
    MessageDetailView(contactUid: "debug")
}
