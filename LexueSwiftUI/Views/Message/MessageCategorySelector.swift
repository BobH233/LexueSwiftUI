//
//  MessageCategorySelector.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/1.
//

import SwiftUI

let messageCategoryChangeNotification = Notification.Name("messageCategoryChangeNotification")

// 模仿钉钉，可以选择未读消息，之后还会添加消息分类功能
struct MessageCategorySelector: View {
    @Environment(\.colorScheme) var sysColorScheme
    @State var categoryOptions = [
        "全部",
        "未读",
        "置顶"
    ]
    @State var currentSelectOption = "全部"
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categoryOptions, id: \.self) { category in
                    ZStack {
                        Rectangle()
                            .foregroundColor(category == currentSelectOption ? .blue.opacity(0.2) : .gray.opacity(0.2))
                            .cornerRadius(10)
                            .shadow(color: .secondary, radius: 1)
                        Text(category)
                            .foregroundColor(category == currentSelectOption ? .blue : (sysColorScheme == .light ? .black.opacity(0.6) : .white.opacity(0.8)))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                    }
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.1)) {
                            currentSelectOption = category
                            NotificationCenter.default.post(name: messageCategoryChangeNotification, object: category)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 10)
        }
        .frame(height: 50)
        .background(.white.opacity(0))
    }
}

#Preview {
    MessageCategorySelector()
}
