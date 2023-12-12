//
//  AppNotificationsView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/29.
//

import SwiftUI
import MarkdownUI

struct NotificationCard: View {
    @State var color: Color = .secondarySystemBackground
    @State var image_name: String = "figure.highintensity.intervaltraining"
    @State var title: String = "我的成绩"
    @State var timeStr: String = "12-02 12:12"
    @State var markdownContent: String = "99分"
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
            VStack {
                HStack() {
                    if !image_name.isEmpty {
                        Image(systemName: image_name)
                            .font(.system(size: 30))
                            .padding(.leading, 20)
                    }
                    Text(title)
                        .bold()
                        .font(.system(size: 30))
                        .padding(.vertical, 10)
                    VStack {
                        Spacer()
                        Text(timeStr)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                    }
                    Spacer()
                }
                .background(Color.systemGray.opacity(0.2))
                HStack {
                    Markdown(markdownContent)
                    Spacer()
                }
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            }
        }
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct AppNotificationsView: View {
    @ObservedObject var appNotificationManager = AppNotificationsManager.shared
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach($appNotificationManager.notificationsList, id: \.notificationId.wrappedValue) { notification in
                    if notification.pinned.wrappedValue {
                        NotificationCard(image_name: "pin.fill", title: "置顶公告", timeStr: GetDateDescriptionText(sendDate: notification.wrappedValue.GetDate()), markdownContent: notification.markdownContent.wrappedValue)
                    }
                }
                ForEach($appNotificationManager.notificationsList, id: \.notificationId.wrappedValue) { notification in
                    if !notification.pinned.wrappedValue {
                        NotificationCard(image_name: "paperplane.fill", title: "公告", timeStr: GetDateDescriptionText(sendDate: notification.wrappedValue.GetDate()), markdownContent: notification.markdownContent.wrappedValue)
                    }
                }
            }
            .frame(maxWidth: 500)
            .padding()
        }
        .onAppear {
            Task {
                await appNotificationManager.UpdateNotifications()
                if appNotificationManager.notificationsList.count > 0 {
                    appNotificationManager.SetReadLatestId(id: appNotificationManager.GetMaxId())
                }
            }
        }
        .navigationTitle("应用公告")
    }
}

#Preview {
    AppNotificationsView()
}
