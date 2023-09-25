//
//  ProfileView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/16.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @State var showUploadSheet = false
    var body: some View {
        Form {
            Section() {
                Button("设置头像") {
                    showUploadSheet.toggle()
                }
            }
            Section() {
                HStack {
                    Text("姓名")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(globalVar.cur_user_info.fullName)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("学号")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(globalVar.cur_user_info.stuId)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("邮箱")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(globalVar.cur_user_info.email)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("手机号")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(globalVar.cur_user_info.phone)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("第一次访问时间")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(globalVar.cur_user_info.firstAccessTime)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showUploadSheet) {
            AvatarSettingView()
        }
        .navigationTitle("个人资料")
    }
}

#Preview {
    ProfileView()
}
