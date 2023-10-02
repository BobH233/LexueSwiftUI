//
//  EventPreferenceSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/1.
//

import SwiftUI

struct EventPreferenceSettingView: View {
    @State private var midnightFixTime = 0
    
    @State private var enableNotification = false
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    var body: some View {
        Form {
            Section() {
                Picker("凌晨跨越时间点", selection: $midnightFixTime) {
                    ForEach(0 ..< 13) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } header: {
                Text("凌晨跨越")
            } footer: {
                Text("设置凌晨跨越选项，你可以选择将第二天\(midnightFixTime)点之前的ddl算作头一天的ddl，以防止错过像凌晨3点截止这样时间的ddl。")
            }
            
            Section() {
                Toggle("开启提醒", isOn: $enableNotification)
                Stepper(value: $selectedHour, in: 0...23) {
                    Text("\(selectedHour) 小时")
                }
                Stepper(value: $selectedMinute, in: 0...59) {
                    Text("\(selectedMinute) 分钟")
                }
            } header: {
                Text("提前提醒时间")
            } footer: {
                Text("当乐学助手定时刷新时，如果距离事件到期还有不到\(selectedHour)小时\(selectedMinute)分钟，那么乐学助手将通过通知提醒您")
            }
        }
        .onChange(of: midnightFixTime) { newVal in
            SettingStorage.shared.event_midnightFixTime = newVal
        }
        .onChange(of: selectedHour) { newVal in
            SettingStorage.shared.event_preHour = newVal
        }
        .onChange(of: selectedMinute) { newVal in
            SettingStorage.shared.event_preMinute = newVal
        }
        .onChange(of: enableNotification) { newVal in
            SettingStorage.shared.event_enableNotification = newVal
        }
        .onAppear {
            midnightFixTime = SettingStorage.shared.event_midnightFixTime
            enableNotification = SettingStorage.shared.event_enableNotification
            selectedHour = SettingStorage.shared.event_preHour
            selectedMinute = SettingStorage.shared.event_preMinute
        }
        .navigationTitle("设置规则")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EventPreferenceSettingView()
}
