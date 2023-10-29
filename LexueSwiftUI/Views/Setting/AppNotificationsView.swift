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
            ForEach($appNotificationManager.notificationsList, id: \.notificationId.wrappedValue) { notification in
                Section(GetDateDescriptionText(sendDate: notification.wrappedValue.GetDate())) {
                    Markdown(notification.markdownContent.wrappedValue)
                }
            }
        }
        .onAppear {
            Task {
                await appNotificationManager.UpdateNotifications()
                if appNotificationManager.notificationsList.count > 0 {
                    appNotificationManager.SetReadLatestId(id: appNotificationManager.notificationsList.first!.notificationId)
                }
            }
        }
        .navigationTitle("应用公告")
    }
}

#Preview {
    AppNotificationsView()
}
