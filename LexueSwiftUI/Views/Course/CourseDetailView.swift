//
//  CourseDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/25.
//

import SwiftUI

struct CourseDetailView: View {
    var courseId: String = "10001"
    
    @State var loading = true
    @State var courseName: String = "这是一个超级长课程名这是一个超级长课程名这是一个超级长课程名"
    
    @State var sections: [LexueAPI.CourseSectionInfo] = [LexueAPI.CourseSectionInfo]()
    
    var body: some View {
        List {
            Section.init {
                ZStack {
                    Rectangle()
                        .foregroundColor(.blue)
                    HStack {
                        Text(courseName)
                            .bold()
                            .font(.system(size: 35))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            .padding(.top, 150)
                            .padding(.bottom, 30)
                        Spacer()
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            if loading {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                        .padding(.top, 10)
                        .tint(.black)
                    Spacer()
                }
            } else {
                Section("课程信息") {
                    NavigationLink("课程简介", destination: EmptyView())
                    NavigationLink("参与人", destination: EmptyView())
                    NavigationLink("成绩", destination: EmptyView())
                    NavigationLink("最近ddl", destination: EmptyView())
                }
                Section("课程内容") {
                    ForEach(sections) { section in
                        NavigationLink("\(section.name!) id: \(section.sectionId!)", destination: EmptyView())
                    }
                }
            }
        }
        .onFirstAppear {
            loading = true
            Task {
                let res = await LexueAPI.shared.GetCourseSections(GlobalVariables.shared.cur_lexue_context, courseId: courseId)
                switch res {
                case .success(let sections):
                    DispatchQueue.main.async {
                        self.sections = sections
                        withAnimation {
                            self.loading = false
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.alertTitle = "无法获取课程的内容(CourseSections)"
                        GlobalVariables.shared.alertContent = "请检查你的网络，然后重试"
                        GlobalVariables.shared.showAlert = true
                    }
                }
            }
        }
        .navigationTitle("课程详情")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#Preview {
    CourseDetailView()
}
