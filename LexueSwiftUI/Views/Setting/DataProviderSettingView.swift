//
//  DataProviderSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/3.
//

import SwiftUI

struct DataProviderDetailView: View {
    var provider: DataProvider
    @State var info: DataProviderInfo = DataProviderInfo()
    
    @State var enable: Bool = false
    @State var allowMessage: Bool = false
    @State var allowNotification: Bool = false
    var body: some View {
        Form {
            Section("信息"){
                HStack {
                    Text("消息源名称")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(info.providerName)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("消息源介绍")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(info.description)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("作者")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(info.author)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("ID")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(info.providerId)
                        .foregroundColor(.secondary)
                }
            }
            Section("设定") {
                Toggle("启用", isOn: $enable)
                if enable {
                    Toggle("允许推送至消息列表", isOn: $allowMessage)
                    if allowMessage {
                        Toggle("允许推送系统通知", isOn: $allowNotification)
                    }
                }
            }
        }
        .onChange(of: enable) { newVal in
            DataProviderManager.shared.setProviderSetting(attribute: "enable", providerId: info.providerId, val: newVal)
        }
        .onChange(of: allowMessage) { newVal in
            DataProviderManager.shared.setProviderSetting(attribute: "allowMessage", providerId: info.providerId, val: newVal)
        }
        .onChange(of: allowNotification) { newVal in
            DataProviderManager.shared.setProviderSetting(attribute: "allowNotification", providerId: info.providerId, val: newVal)
        }
        .onAppear {
            info = provider.info()
            enable = provider.enabled
            allowMessage = provider.allowMessage
            allowNotification = provider.allowNotification
        }
        .navigationTitle(info.providerName)
    }
}

struct DataProviderSettingView: View {
    var body: some View {
        Form {
            Section("消息源") {
                ForEach(DataProviderManager.shared.dataProviders, id: \.providerId) { provider in
                    NavigationLink(provider.info().providerName , destination: {
                        DataProviderDetailView(provider: provider)
                    })
                }
            }
        }
        .navigationTitle("消息源设定")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    DataProviderSettingView()
}
