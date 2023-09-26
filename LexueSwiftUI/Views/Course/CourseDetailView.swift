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
    
    // 删除lexue的相关的杂项
    let deleteLexueMiscJs = """
        function __remove() {
            let __a = document.getElementById("header");
            if(__a != null) __a.parentNode.removeChild(__a);
            __a = document.getElementsByClassName("header-main")[0];
            if(__a != null) __a.parentNode.removeChild(__a);
            __a = document.getElementById("page-navbar");
            if(__a != null) __a.parentNode.removeChild(__a);
            __a = document.getElementById("nav-drawer");
            if(__a != null) __a.parentNode.removeChild(__a);
            __a = document.getElementById("nav-drawer");
            if(__a != null) __a.parentNode.removeChild(__a);
            __a = document.getElementsByTagName("footer")
            for(let i=0;i<__a.length;i++) {__a[i].parentNode.removeChild(__a[i]);}
        }
        for(let i=0;i<10;i++) __remove();
    """
    
    
    // 删除前一个活动、后一个活动的标识
    let deleteArrowJs = """
        function __remove2() {
            let __b = document.getElementsByClassName("mdl-left");
            for(let i=0;i<__b.length;i++) {__b[i].parentNode.removeChild(__b[i]);}
            __b = document.getElementsByClassName("mdl-right");
            for(let i=0;i<__b.length;i++) {__b[i].parentNode.removeChild(__b[i]);}
        }
        for(let i=0;i<10;i++) __remove2();
    """
    
    let fixScrollProblemJs = """
        let __c = document.getElementById("region-main");
        if(__c != null) __c.style="overflow: hidden;";
    """
    
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
                    NavigationLink("最近ddl", destination: EmptyView())
                }
                Section("课程内容") {
                    ForEach(sections) { section in
                        NavigationLink("\(section.name!)", destination: LexueBroswerView(url: "https://lexue.bit.edu.cn/course/view.php?id=\(courseId)&section=\(section.sectionId ?? "0")", execJs: deleteLexueMiscJs + deleteArrowJs + fixScrollProblemJs).navigationTitle(section.name!))
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

