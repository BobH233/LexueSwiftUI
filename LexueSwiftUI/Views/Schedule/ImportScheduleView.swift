//
//  ImportScheduleView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/24.
//

import SwiftUI

struct ScheduleCourseImportPreviewCard: View {
    
    @Environment(\.colorScheme) var sysColorScheme
    
    var sideBarColor: Color = .blue
    var courseName: String = "114514[控制科学]"

    var teacherName: String = "金海"
    var courseLocationAndTime: String = "233"
    var credit: String = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.secondarySystemBackground)
            HStack {
                Rectangle()
                    .foregroundColor(sideBarColor)
                    .frame(width: 10)
                Spacer()
            }
            VStack(spacing: 5) {
                HStack {
                    Text(courseName)
                        .bold()
                        .lineLimit(nil)
                        .font(.system(size: 24))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(.top, 10)
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("老师:")
                        .bold()
                    Text(teacherName.GuardNotEmpty())
                    Spacer()
                }
                HStack {
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.blue)
                            Text("地点时间:")
                                .bold()
                        }
                        Spacer()
                    }
                    VStack {
                        Text(courseLocationAndTime.GuardNotEmpty())
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.orange)
                    Text("学分:")
                        .bold()
                    Text(credit.GuardNotEmpty())
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 30)
        }
        .frame(maxHeight: .infinity)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ImportScheduleView: View {
    @State var isLoadedSchedule = false
    @Environment(\.colorScheme) var sysColorScheme
    @State var importButtonDisable = false
    @State var JXZX_context = JXZXehall.JXZXContext()
    @State var inited = false
    
    @State var semester: [FilterOptionBool] = [
    ]
    
    @State var currentSemeCourse: [JXZXehall.ScheduleCourseInfo] = [
        
    ]
    
    @State var uniqueSemeCourse: [JXZXehall.ScheduleCourseInfo] = [
        .init(KKDWDM_DISPLAY: "啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦", CourseName: "哦哦哦哦哦哦哦哦哦哦哦", TeacherName: "急急急急急急急急急")
    ]
    
    func ImportSchedule() {
        Task {
            var selection: String = ""
            for sel_option in semester {
                if sel_option.choose {
                    selection = sel_option.title
                    break
                }
            }
            if selection.isEmpty {
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "未选择导入学期"
                    GlobalVariables.shared.alertContent = "请选择一个学期"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            DispatchQueue.main.async {
                importButtonDisable = true
            }
            let result = await JXZXehall.shared.GetJXZXwdkbbyContext(loginnedContext: SettingStorage.shared.loginnedContext)
            switch result {
            case .success(let context):
                JXZX_context = context
                print(context)
            case .failure(_):
                DispatchQueue.main.async {
                    self.importButtonDisable = false
                    GlobalVariables.shared.alertTitle = "登录教学中心失败"
                    GlobalVariables.shared.alertContent = "请检查网络或者退出重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            let course_res = await JXZXehall.shared.GetSemesterScheduleCourses(context: JXZX_context, semesterId: selection)
            switch course_res {
            case .success(let context):
                DispatchQueue.main.async {
                    currentSemeCourse = context
                    withAnimation {
                        uniqueSemeCourse = ScheduleManager.shared.GetUniqueScheduleCourseInfo(allInfo: currentSemeCourse)
                        self.importButtonDisable = false
                        isLoadedSchedule = true
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.importButtonDisable = false
                    GlobalVariables.shared.alertTitle = "获取\(selection)学期课程失败"
                    GlobalVariables.shared.alertContent = "请检查网络或者退出重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
        }
    }
    
    func LoadSemesterInfo() {
        print("LoadSemesterInfo...")
        inited = false
        Task {
            var currentContext = JXZXehall.JXZXContext()
            var currentSemesterId: String = ScheduleManager.shared.GetSemesterInfo()
            semester.append(.init(title: currentSemesterId, choose: true))
            DispatchQueue.main.async {
                inited = true
            }
//            let context_result = await JXZXehall.shared.GetJXZXMobileContext(loginnedContext: SettingStorage.shared.loginnedContext)
//            print("GetJXZXMobileContext!")
//            switch context_result {
//            case .success(let context):
//                currentContext = context
//            case .failure(_):
//                DispatchQueue.main.async {
//                    GlobalVariables.shared.alertTitle = "无法访问教学中心"
//                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
//                    GlobalVariables.shared.showAlert = true
//                }
//                return
//            }
//            
//            let all_semesters = await JXZXehall.shared.GetAllSemesterInfo(context: currentContext)
//            print("GetAllSemesterInfo!")
//            switch all_semesters {
//            case .success(let semesterInfo):
//                DispatchQueue.main.async {
//                    for sem in semesterInfo {
//                        semester.append(.init(title: sem.semesterId, choose: sem.semesterId == currentSemesterId))
//                    }
//                    inited = true
//                }
//            case .failure(_):
//                DispatchQueue.main.async {
//                    GlobalVariables.shared.alertTitle = "无法拉取全部学期信息"
//                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
//                    GlobalVariables.shared.showAlert = true
//                }
//                return
//            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("从教务导入课表")
                        .bold()
                        .font(.title)
                    Spacer()
                }
                .padding(.horizontal, 20)
                if inited {
                    if !isLoadedSchedule {
                        ContentCardView(title0: "选择学期", color0: .systemBlue) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach($semester, id: \.title) { choice in
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(choice.choose.wrappedValue ? .blue : .secondarySystemBackground)
                                                .cornerRadius(10)
                                                .shadow(color: .secondary, radius: 1)
                                            Text(choice.title.wrappedValue)
                                                .bold()
                                                .foregroundColor(choice.choose.wrappedValue ? .white : (sysColorScheme == .light ? .black : .white))
                                                .padding()
                                        }
                                        .onTapGesture {
                                            // 将其他的选项设置为未选中
                                            withAnimation(.spring(duration: 0.1)) {
                                                for i in 0 ..< semester.count {
                                                    if semester[i].title == choice.title.wrappedValue {
                                                        continue
                                                    }
                                                    semester[i].choose = false
                                                }
                                                choice.choose.wrappedValue = true
                                            }
                                        }
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 10)
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 20)
                    }
                    if !isLoadedSchedule {
                        Button {
                            ImportSchedule()
                        } label: {
                            Text(importButtonDisable ? "正在导入..." : "导入课表")
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundColor(.white)
                        }
                        .disabled(importButtonDisable)
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 10)
                    } else {
                        Button {
                            
                        } label: {
                            Text("确认导入")
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding(.top, 10)
                    }
                    if true {
                        VStack(spacing: 20) {
                            HStack {
                                Text("课程信息")
                                    .bold()
                                    .font(.title)
                                Spacer()
                            }
                            .padding(.top, 20)
                            ForEach(uniqueSemeCourse, id: \.CourseId) { course in
                                ScheduleCourseImportPreviewCard(courseName: "\(course.CourseName)[\(course.KKDWDM_DISPLAY)]", teacherName: course.TeacherName, courseLocationAndTime: course.ClassroomLocationTimeDes, credit: "\(course.CourseCredit)")
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                }
                else {
                    ProgressView()
                        .controlSize(.large)
                        .padding(.top, 20)
                        .onFirstAppear {
                            LoadSemesterInfo()
                        }
                }
            }
            .padding(15)
        }
        .foregroundColor(sysColorScheme == .light ? .black : .white)
    }
}

#Preview {
    ImportScheduleView()
}
