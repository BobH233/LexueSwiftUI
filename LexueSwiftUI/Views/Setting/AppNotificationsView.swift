//
//  AppNotificationsView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/29.
//

import SwiftUI
import MarkdownUI

struct AppNotificationsView: View {
    @ObservedObject var appNotificationManager = AppNotificationsManager.shared
    var body: some View {
        Form {
            Text("置顶公告")
                .font(.system(size: 40))
                .bold()
                .foregroundColor(.blue)
            ForEach($appNotificationManager.notificationsList, id: \.notificationId.wrappedValue) { notification in
                if notification.pinned.wrappedValue {
                    Section(GetDateDescriptionText(sendDate: notification.wrappedValue.GetDate())) {
                        Markdown(notification.markdownContent.wrappedValue)
                    }
                }
            }
            Text("其他公告")
                .font(.system(size: 40))
                .bold()
                .foregroundColor(.blue)
            ForEach($appNotificationManager.notificationsList, id: \.notificationId.wrappedValue) { notification in
                if !notification.pinned.wrappedValue {
                    Section(GetDateDescriptionText(sendDate: notification.wrappedValue.GetDate())) {
                        Markdown(notification.markdownContent.wrappedValue)
                    }
                }
            }
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
