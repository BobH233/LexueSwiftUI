//
//  CourseDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/25.
//

import SwiftUI

struct CourseSummaryView: View {
    var courseSummary: String = ""
    struct HTMLText: View {
        var html = "<b>This is</b> <i>rich</i> <u>HTML</u> <span style=\"color: red;\">text</span>."
        @State var attributedString: AttributedString? = nil
        @State var attributeStringDarkMode: AttributedString? = nil
        @Environment(\.colorScheme) var colorScheme
        var body: some View {
            ZStack {
                if attributedString != nil && attributeStringDarkMode != nil {
                    Text(colorScheme == .dark ? attributeStringDarkMode! : attributedString!)
                } else {
                    Text(html)
                }
            }
            .onAppear {
                if let nsAttributedString = try? NSAttributedString(data: Data(html.data(using: String.Encoding.unicode)!), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
                   var attributedString1 = try? AttributedString(nsAttributedString, including: \.uiKit) {
                    attributedString1.foregroundColor = .black
                    attributedString = attributedString1
                    var attributedString2 = try? AttributedString(nsAttributedString, including: \.uiKit)
                    attributedString2?.foregroundColor = .white
                    attributeStringDarkMode = attributedString2
                }
            }
                
        }
    }
    var body: some View {
        Form {
            HTMLText(html: courseSummary)
                .textSelection(.enabled)
        }
        .navigationTitle("课程简介")
        .navigationBarTitleDisplayMode(.large)
    }
}


struct CourseDetailView: View {
    var courseId: String = "10001"
    
    @State var courseInfo: CourseShortInfo
    @State var loading = true
    @State var courseName: String
    
    @State var sections: [LexueAPI.CourseSectionInfo] = [LexueAPI.CourseSectionInfo]()
    
    var body: some View {
        
        List {
            Section.init {
                ZStack {
                    Rectangle()
                        .foregroundColor(.blue)
                    HStack {
                        Spacer()
                        Text(courseName)
                            .bold()
                            .font(.system(size: 35))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
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
                    Spacer()
                }
            } else {
                Section("课程信息") {
                    if courseInfo.summary != nil && !courseInfo.summary!.isEmpty {
                        NavigationLink("课程简介", destination: CourseSummaryView(courseSummary: courseInfo.summary!))
                    }
                    NavigationLink("参与人", destination: CourseMembersListView(courseId: courseId))
                    NavigationLink("成绩", destination: LexueBroswerView(url: "https://lexue.bit.edu.cn/grade/report/user/index.php?id=\(courseId)").navigationTitle("查看成绩"))
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

