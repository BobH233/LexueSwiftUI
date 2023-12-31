//
//  DataProviderSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/3.
//

import SwiftUI

struct DataProviderDetailView: View {
    var provider: DataProvider
    @State var currentOptions: [ProviderCustomOption] = []
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
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("作者")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(info.author)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                if let author_url = info.author_url, let url = URL(string: author_url) {
                    HStack {
                        Text("作者链接")
                            .foregroundColor(.primary)
                        Spacer()
                        Link(author_url, destination: url)
                    }
                }
                HStack {
                    Text("ID")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(info.providerId)
                        .foregroundColor(.secondary)
                }
            }
            Section("系统设定") {
                Toggle("启用", isOn: $enable)
                if enable {
                    Toggle("允许推送至消息列表", isOn: $allowMessage)
                    if allowMessage {
                        Toggle("允许推送系统通知", isOn: $allowNotification)
                    }
                }
            }
            if provider.customOptions.count > 0 {
                Section("消息源内容设定") {
                    ForEach($currentOptions, id:\.optionName.wrappedValue) { option in
                        if option.optionType.wrappedValue == .bool {
                            Toggle(option.displayName.wrappedValue, isOn: option.optionValueBool)
                        } else if option.optionType.wrappedValue == .string {
                            HStack {
                                Text(option.displayName.wrappedValue)
                                Spacer()
                                TextField(option.displayName.wrappedValue, text: option.optionValueString)
                            }
                        }
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
        .onDisappear {
            DataProviderManager.shared.saveProviderCustomSettings(providerId: info.providerId, newOptionValue: currentOptions)
        }
        .onAppear {
            info = provider.info()
            enable = provider.enabled
            allowMessage = provider.allowMessage
            allowNotification = provider.allowNotification
            currentOptions = provider.customOptions
        }
        .navigationTitle(info.providerName)
    }
}

struct DataProviderSettingView: View {
    @ObservedObject var providerManager = DataProviderManager.shared
    @State var use_apns = false
    var body: some View {
        Form {
            Section() {
                Toggle("使用云推送方式", isOn: $use_apns)
            } header: {
                Text("拉取方式")
            } footer: {
                Text("默认采用的消息推送方式，打开后，将更节省流量，接收消息更及时。如果您发现有遗漏消息，请关闭这个功能，以确保消息接收的完整性")
            }
            Section() {
                ForEach(providerManager.dataProviders, id: \.providerIdForEach) { provider in
                    NavigationLink(provider.info().providerName , destination: {
                        DataProviderDetailView(provider: provider)
                    })
                    .isDetailLink(false)
                }
            } header: {
                Text("消息源")
            } footer: {
                Text("这些是乐学助手内置的可以向您发送消息的消息源，您可以点击进行更详细的设置，包括是否启用，是否发送通知等等")
            }
            
        }
        .onAppear {
            use_apns = SettingStorage.shared.prefer_disable_background_fetch
        }
        .onChange(of: use_apns) { newVal in
            SettingStorage.shared.prefer_disable_background_fetch = newVal
        }
        .navigationViewStyle(.stack)
        .navigationTitle("消息源设定")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    DataProviderSettingView()
}
