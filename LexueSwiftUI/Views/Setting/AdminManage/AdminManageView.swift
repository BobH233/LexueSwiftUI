//
//  AdminManageView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/18.
//

import SwiftUI

struct AdminManageView: View {
    @State var adminKey = ""
    var body: some View {
        Form {
            Section("管理员密匙") {
                TextField("管理员密匙", text: $adminKey)
            }
            Section("公告管理") {
                NavigationLink("添加新公告", destination: AddNotificationView())
                    .isDetailLink(true)
            }
            
        }
        .onAppear {
            adminKey = SettingStorage.shared.adminKey
        }
        .onChange(of: adminKey) { newVal in
            SettingStorage.shared.adminKey = newVal
        }
        .navigationTitle("管理后台")
    }
}

#Preview {
    AdminManageView()
}
