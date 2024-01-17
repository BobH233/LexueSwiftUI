//
//  EditNotificationView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/1/17.
//

import SwiftUI

struct CurrentNotificationCard: View {
    @Environment(\.colorScheme) var sysColorScheme
    
    var isPinned: Bool = false
    var isPopup: Bool = false
    var isHidden: Bool = true
    var versions: [String] = ["1.3", "1.4"]
    var markdownContent: String = "# lalala"
    var timeStr: String = "12-02 12:12"
    var id: String = "114514"
    var sideBarColor: Color = .blue
    
    
    func GetVersionsString() -> String {
        return versions.count == 0 ? "所有版本" : versions.joined(separator: ", ")
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.secondarySystemBackground)
            HStack {
                Rectangle()
                    .foregroundColor(sideBarColor)
                    .frame(width: 10)
                Spacer()
            }
            VStack(spacing: 5) {
                HStack {
                    Text(isPinned ? "置顶公告" : "普通公告")
                        .bold()
                        .font(.system(size: 24))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.top, 10)
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("消息ID:")
                        .bold()
                    Text(id)
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("是否是弹出消息:")
                        .bold()
                    Text(isPopup ? "是" : "否")
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("是否已隐藏:")
                        .bold()
                    Text(isHidden ? "是" : "否")
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("适用版本:")
                        .bold()
                    Text(GetVersionsString())
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("最后修改日期:")
                        .bold()
                    Text(timeStr)
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("内容:")
                        .bold()
                    Text(markdownContent)
                    Spacer()
                }
                .padding(.bottom, 10)
                
            }
            .padding(.leading, 30)
        }
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct EditNotificationView: View {
    @State var notifications: [LexueHelperBackend.AppNotification] = []
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(notifications, id: \.notificationId) { notification in
                    CurrentNotificationCard(isPinned: notification.pinned, isPopup: notification.isPopupNotification, isHidden: notification.isHide != 0, versions: notification.appVersionLimit, markdownContent: notification.markdownContent, timeStr: GetDateDescriptionText(sendDate: notification.GetDate()), id: "\(notification.notificationId)")
                }
            }
            .frame(maxWidth: 500)
            .padding()
        }
        .onAppear {
            Task {
                let result = await LexueHelperBackend.shared.FetchAppNotifications(onlyThisVersion: false)
                DispatchQueue.main.async {
                    notifications = result
                }
            }
        }
    }
}

#Preview {
    CurrentNotificationCard()
}
