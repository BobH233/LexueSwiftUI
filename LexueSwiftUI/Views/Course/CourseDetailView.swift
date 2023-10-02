//
//  CourseDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/25.
//

import SwiftUI

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

struct CourseSummaryView: View {
    var courseSummary: String = ""
    var body: some View {
        Form {
            HTMLText(html: courseSummary)
                .textSelection(.enabled)
        }
        .navigationTitle("课程简介")
        .navigationBarTitleDisplayMode(.large)
    }
}
// 删除lexue的相关的杂项
let deleteLexueMiscJs = """
    function __remove() {
        let __a = document.getElementById("header");
        if(__a != null) __a.parentNode.removeChild(__a);
        __a = document.querySelectorAll('a[data-action=\"tool_usertours/resetpagetour\"]')[0];
        if(__a != null) __a.parentNode.removeChild(__a);
        __a = document.getElementsByClassName("header-main")[0];
        if(__a != null) __a.parentNode.removeChild(__a);
        __a = document.getElementById("page-navbar");
        if(__a != null) __a.parentNode.removeChild(__a);
        __a = document.getElementById("nav-drawer");
        if(__a != null) __a.parentNode.removeChild(__a);
        __a = document.getElementById("nav-drawer");
        if(__a != null) __a.parentNode.removeChild(__a);
        __a = document.getElementsByTagName("footer");
        for(let i=0;i<__a.length;i++) {__a[i].parentNode.removeChild(__a[i]);}
    }
    for(let i=0;i<10;i++) __remove();
    setInterval(__remove, 1000);
"""


// 删除前一个活动、后一个活动的标识
let deleteArrowJs = """
    function __remove2() {
        let __b = document.querySelector("span.mdl-left");
        if(__b != null) __b.parentNode.removeChild(__b);
        __b = document.querySelector("span.mdl-right");
        if(__b != null) __b.parentNode.removeChild(__b);
    }
    for(let i=0;i<10;i++) __remove2();
"""

let fixScrollProblemJs = """
    let __c = document.getElementById("region-main");
    if(__c != null) __c.style="overflow-x: visible; overflow-y: visible; white-space: nowrap";
"""

// 删除编程排行榜等杂七杂八东西
let deleteSizePreJs = """
    let __d = document.getElementById("block-region-side-pre");
    if(__d != null) __d.parentNode.removeChild(__d);
"""

// 在进入非0小节时，删除掉前面0小节的东西
let delete_section0_contentJs = """
    let __e = document.querySelector('li[data-sectionid="0"]');
    if(__e != null) __e.parentNode.removeChild(__e);
"""

struct CourseSectionView: View {
    var sectionInfo: LexueAPI.CourseSectionInfo
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                if sectionInfo.current {
                    Text(sectionInfo.name ?? "[无名字小节]")
                        .bold()
                        .foregroundColor(.blue)
                } else {
                    Text(sectionInfo.name ?? "[无名字小节]")
                }
                Spacer()
            }
            if sectionInfo.file_cnt != nil || sectionInfo.assignment_cnt != nil || sectionInfo.forum_cnt != nil || (sectionInfo.progress_finish != nil && sectionInfo.progress_total != nil) || sectionInfo.test_cnt != nil || sectionInfo.coding_cnt != nil {
                HStack() {
                    if let file_cnt = sectionInfo.file_cnt {
                        HStack (spacing: 2){
                            Image(systemName: "doc.fill")
                                .foregroundColor(.secondary)
                            Text("\(file_cnt)")
                                .foregroundColor(.secondary)
                        }
                    }
                    if let assignment_cnt = sectionInfo.assignment_cnt {
                        HStack (spacing: 2){
                            Image(systemName: "highlighter")
                                .foregroundColor(.secondary)
                            Text("\(assignment_cnt)")
                                .foregroundColor(.secondary)
                        }
                    }
                    if let coding_cnt = sectionInfo.coding_cnt {
                        HStack (spacing: 2){
                            Image(systemName: "keyboard.fill")
                                .foregroundColor(.secondary)
                            Text("\(coding_cnt)")
                                .foregroundColor(.secondary)
                        }
                    }
                    if let test_cnt = sectionInfo.test_cnt {
                        HStack (spacing: 2){
                            Image(systemName: "function")
                                .foregroundColor(.secondary)
                            Text("\(test_cnt)")
                                .foregroundColor(.secondary)
                        }
                    }
                    if let forum_cnt = sectionInfo.forum_cnt {
                        HStack (spacing: 2){
                            Image(systemName: "bubble.right.fill")
                                .foregroundColor(.secondary)
                            Text("\(forum_cnt)")
                                .foregroundColor(.secondary)
                        }
                    }
                    if let progress_finish = sectionInfo.progress_finish, let progress_total = sectionInfo.progress_total {
                        HStack (spacing: 2){
                            Image(systemName: "timer.circle.fill")
                                .foregroundColor(.secondary)
                            Text("\(progress_finish)/\(progress_total)")
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
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
                    NavigationLink("成绩", destination: LexueBroswerView(url: "https://lexue.bit.edu.cn/grade/report/user/index.php?id=\(courseId)", execJs: deleteLexueMiscJs).navigationTitle("查看成绩"))
                }
                Section() {
                    ForEach(sections) { section in
                        NavigationLink(destination: LexueBroswerView(url: "https://lexue.bit.edu.cn/course/view.php?id=\(courseId)&section=\(section.sectionId ?? "0")", execJs: deleteLexueMiscJs + deleteArrowJs + fixScrollProblemJs + deleteSizePreJs + (section.sectionId! == "0" ? "" : delete_section0_contentJs)).navigationTitle(section.name!), label: {
                            CourseSectionView(sectionInfo: section)
                        })
                    }
                } header: {
                    Text("课程内容")
                } footer: {
                    VStack(alignment: .leading){
                        HStack (spacing: 5){
                            HStack (spacing: 2){
                                Image(systemName: "highlighter")
                                    .foregroundColor(.secondary)
                                Text("作业")
                                    .foregroundColor(.secondary)
                            }
                            HStack (spacing: 2){
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.secondary)
                                Text("文件")
                                    .foregroundColor(.secondary)
                            }
                            HStack (spacing: 2){
                                Image(systemName: "bubble.right.fill")
                                    .foregroundColor(.secondary)
                                Text("讨论")
                                    .foregroundColor(.secondary)
                            }
                        }
                        HStack (spacing: 5) {
                            HStack (spacing: 2){
                                Image(systemName: "keyboard.fill")
                                    .foregroundColor(.secondary)
                                Text("编程练习")
                                    .foregroundColor(.secondary)
                            }
                            HStack (spacing: 2){
                                Image(systemName: "function")
                                    .foregroundColor(.secondary)
                                Text("测验")
                                    .foregroundColor(.secondary)
                            }
                            HStack (spacing: 2){
                                Image(systemName: "timer.circle.fill")
                                    .foregroundColor(.secondary)
                                Text("完成进度")
                                    .foregroundColor(.secondary)
                            }
                        }
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

