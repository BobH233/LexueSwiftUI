//
//  AddNotificationView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/18.
//

import SwiftUI

struct AddNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @State var isEditMode = false
    @State var editId = "0"
    @State var pinned = false
    @State var isPopup = false
    @State var appVersionLim = ""
    @State var markdownContent = "## 这是一则公告示例"
    
    func AddNewNotification() {
        Task {
            var limArr = appVersionLim.split(whereSeparator: \.isNewline)
                .map(String.init)
                .filter { !$0.isEmpty }
            let res = await LexueHelperBackend.shared.Admin_AddAppNotification(adminToken: SettingStorage.shared.adminKey, markdownContent: markdownContent, pinned: pinned, isPopupNotification: isPopup, appVersionLimit: limArr)
            if res {
                DispatchQueue.main.async {
                    dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "添加失败"
                    GlobalVariables.shared.alertContent = "检查adminkey或者重试"
                    GlobalVariables.shared.showAlert = true
                }
            }
        }
    }
    
    var body: some View {
        Form {
            if isEditMode {
                Section("待修改的公告信息") {
                    HStack {
                        Text("公告ID:")
                        Text(editId)
                            .foregroundColor(.secondary)
                    }
                    
                }
            }
            Section("基本设置") {
                Toggle("是否置顶", isOn: $pinned)
                Toggle("是否是弹出消息", isOn: $isPopup)
            }
            if #available(iOS 16.0, *) {
                Section("公告适用版本设置"){
                    TextField("App版本限制(换行隔开)", text: $appVersionLim, axis: .vertical)
                    
                }
            }
            if #available(iOS 16.0, *) {
                Section("公告内容设置(markdown)"){
                    TextField("markdown公告内容", text: $markdownContent, axis: .vertical)
                    NavigationLink("预览公告", destination: MarkdownPreview(makrdownContent: $markdownContent, isPinned: $pinned))
                }
            }
            Section("执行修改") {
                if isEditMode {
                    Button("修改公告") {
                        
                    }
                } else {
                    Button("添加新公告") {
                        AddNewNotification()
                    }
                }
            }
        }
        .navigationTitle(isEditMode ? "修改公告" : "添加新公告")
    }
}

#Preview {
    AddNotificationView()
}
