//
//  CourseMemberListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/26.
//

import SwiftUI

private struct CourseMemberItemView: View {
    @Binding var memberInfo: LexueAPI.CourseMemberInfo
    
    var body: some View {
        ZStack {
            HStack {
                Image("default_avatar")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                VStack(alignment: .leading, spacing: 3){
                    HStack{
                        Text("\(memberInfo.name!)")
                            .lineLimit(1)
                        Spacer()
                        HStack {
                            Text("\(memberInfo.role ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text("\(memberInfo.group ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(minHeight: 30)
                }
            }
        }
    }
}

struct CourseMembersListView: View {
    var courseId: String = "123"
    @State private var loading: Bool = true
    @State private var members: [LexueAPI.CourseMemberInfo] = [LexueAPI.CourseMemberInfo]()
    @State private var searchText: String = ""
    var body: some View {
        List {
            if loading {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                        .padding(.top, 10)
                    Spacer()
                }
            } else {
                ForEach($members) { member in
                    if searchText.isEmpty || (member.name.wrappedValue!.contains(searchText)) {
                        CourseMemberItemView(memberInfo: member)
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索参与人")
        .navigationTitle("课程参与人(\(members.count))")
        .navigationBarTitleDisplayMode(.large)
        .onFirstAppear {
            loading = true
            Task {
                let res = await LexueAPI.shared.GetCourseMembersInfo(GlobalVariables.shared.cur_lexue_context, sesskey: GlobalVariables.shared.cur_lexue_sessKey, courseId: courseId)
                switch res {
                case .success(let members):
                    DispatchQueue.main.async {
                        self.members = members
                        withAnimation {
                            self.loading = false
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.alertTitle = "无法获取课程参与人(CourseMembers)"
                        GlobalVariables.shared.alertContent = "请检查你的网络，然后重试"
                        GlobalVariables.shared.showAlert = true
                    }
                }
            }
        }
    }
}
