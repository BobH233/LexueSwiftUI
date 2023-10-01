//
//  EventPreferenceSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/1.
//

import SwiftUI

struct EventPreferenceSettingView: View {
    @State private var midnightFixTime = 0
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
        }
        .onChange(of: midnightFixTime) { newVal in
            SettingStorage.shared.midnightFixTime = midnightFixTime
        }
        .onAppear {
            midnightFixTime = SettingStorage.shared.midnightFixTime
        }
        .navigationTitle("设置规则")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EventPreferenceSettingView()
}
