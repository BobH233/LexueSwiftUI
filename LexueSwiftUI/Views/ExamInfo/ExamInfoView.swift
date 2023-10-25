//
//  ExamInfoView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/16.
//

import SwiftUI

struct UnscheduledExamCardView: View {
    @Environment(\.colorScheme) var sysColorScheme
    
    var sideBarColor: Color = .blue
    var courseName: String = "114514[控制科学]"
    var examType: String = "(本)分散考试"
    var teacherName: String = "金海"
    
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
                        .font(.system(size: 24))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.top, 10)
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(sideBarColor)
                    Text("考试类型:")
                        .bold()
                    Text(examType.GuardNotEmpty())
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(sideBarColor)
                    Text("老师:")
                        .bold()
                    Text(teacherName.GuardNotEmpty())
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .padding(.leading, 30)
        }
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ArrangedExamCardView: View {
    @Environment(\.colorScheme) var sysColorScheme
    
    var sideBarColor: Color = .blue
    var courseName: String = "114514[控制科学]"
    var examType: String = "(本)分散考试"
    var teacherName: String = "金海"
    var seatNumber: String = "233"
    var examTime: String = ""
    var examLocation: String = ""
    
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
                        .font(.system(size: 24))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.top, 10)
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("考试类型:")
                        .bold()
                    Text(examType.GuardNotEmpty())
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.blue)
                    Text("老师:")
                        .bold()
                    Text(teacherName.GuardNotEmpty())
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.orange)
                    Text("座位号:")
                        .bold()
                    Text(seatNumber.GuardNotEmpty())
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.orange)
                    Text("考试时间:")
                        .bold()
                    Text(examTime.GuardNotEmpty())
                    Spacer()
                }
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.orange)
                    Text("地点:")
                        .bold()
                    Text(examLocation.GuardNotEmpty())
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .padding(.leading, 30)
        }
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ExamInfoView: View {
    @Environment(\.colorScheme) var sysColorScheme
    
    @State var inited: Bool = false
    @State var loadingNew: Bool = false
    
    @State var JXZXContext = JXZXehall.JXZXContext()
    @State var semester: [FilterOptionBool] = []
    @State var arrangedExam: [JXZXehall.ExamInfo] = []
    @State var finishedExam: [JXZXehall.ExamInfo] = []
    @State var unscheduledExam: [JXZXehall.UnscheduledExamInfo] = []
    
    @Environment(\.managedObjectContext) var managedObjContext
    
    func FetchSemesterInfo(semesterId: String) {
        withAnimation {
            loadingNew = true
            finishedExam = []
            arrangedExam = []
            unscheduledExam = []
        }
        Task {
            let current_exams = await JXZXehall.shared.GetArrangedExam(context: JXZXContext, semesterId: semesterId)
            
            switch current_exams {
            case .success(let success):
                DispatchQueue.main.async {
                    for exam in success {
                        if exam.IsFinished() {
                            finishedExam.append(exam)
                        } else {
                            arrangedExam.append(exam)
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法拉取当前学期考试"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            let unscheduled_exams = await JXZXehall.shared.GetUnscheduledExam(context: JXZXContext, semesterId: semesterId)
            
            switch unscheduled_exams {
            case .success(let success):
                DispatchQueue.main.async {
                    unscheduledExam = success
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法拉取当前学期未安排的考试"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    loadingNew = false
                }
            }
        }
    }
    
    func GetDescriptionOfExam(_ exam: JXZXehall.ExamInfo) -> String {
        var ret = ""
        if !exam.examLocation.isEmpty {
            ret += "地点: \(exam.examLocation); "
        }
        if !exam.examTime.isEmpty {
            ret += "时间: \(exam.examTime); "
        }
        if !exam.seatIndex.isEmpty {
            ret += "座位号: \(exam.seatIndex); "
        }
        return ret
    }
    
    // 导入考试到事件，对于已经存在的事件，则是更新
    func ImportOrUpdateExam() {
        var import_cnt = 0
        var update_cnt = 0
        for exam in arrangedExam {
            print(exam.courseName)
            if let found = DataController.shared.findEventByExamCourseId(examCourseId: exam.courseId, context: managedObjContext) {
                // 更新信息即可
                print("-> Update")
                found.isCustomEvent = true
                found.name = "考试: \(exam.courseName)"
                found.event_description = GetDescriptionOfExam(exam)
                found.is_period_event = true
                found.timestart = exam.GetExamStartDate()
                found.timeend = exam.GetExamEndDate()
                found.event_type = "exam"
                DataController.shared.save(context: managedObjContext)
                update_cnt += 1
            } else {
                print("-> New")
                // 新建考试项
                DataController.shared.addEventStored(isCustomEvent: true, event_name: "考试: \(exam.courseName)", event_description: GetDescriptionOfExam(exam), lexue_id: nil, timestart: exam.GetExamStartDate(), timeusermidnight: nil, mindaytimestamp: nil, course_id: nil, course_name: nil, color: .orange, action_url: nil, event_type: "exam", instance: nil, url: nil, examCourseId: exam.courseId, isPeriodEvent: true, timeend: exam.GetExamEndDate(), lastUpdateDate: Date(), context: managedObjContext)
                import_cnt += 1
            }
        }
        DispatchQueue.main.async {
            GlobalVariables.shared.alertTitle = "成功导入考试信息"
            GlobalVariables.shared.alertContent = "新增了\(import_cnt)个考试事件，更新了\(update_cnt)个考试事件"
            GlobalVariables.shared.showAlert = true
        }
    }
    
    func initExamInfo() {
        inited = false
        Task {
            var currentContext = JXZXehall.JXZXContext()
            var currentSemesterId: String = ""
            let context_result = await JXZXehall.shared.GetJXZXContext(loginnedContext: SettingStorage.shared.loginnedContext)
            switch context_result {
            case .success(let context):
                DispatchQueue.main.async {
                    JXZXContext = context
                }
                currentContext = context
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法访问教学中心"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            let all_semesters = await JXZXehall.shared.GetAllSemesterInfo(context: currentContext)
            switch all_semesters {
            case .success(let semesterInfo):
                DispatchQueue.main.async {
                    for sem in semesterInfo {
                        semester.append(.init(title: sem.semesterId, choose: false))
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法拉取全部学期信息"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            let current_semesters = await JXZXehall.shared.GetCurrentSemesterInfo(context: currentContext)
            switch current_semesters {
            case .success(let success):
                currentSemesterId = success.semesterId
                DispatchQueue.main.async {
                    for i in 0 ..< semester.count {
                        if semester[i].title == success.semesterId {
                            semester[i].choose = true
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法拉取当前学期信息"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            let current_exams = await JXZXehall.shared.GetArrangedExam(context: currentContext, semesterId: currentSemesterId)
            
            switch current_exams {
            case .success(let success):
                DispatchQueue.main.async {
                    for exam in success {
                        if exam.IsFinished() {
                            finishedExam.append(exam)
                        } else {
                            arrangedExam.append(exam)
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法拉取当前学期考试"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            let unscheduled_exams = await JXZXehall.shared.GetUnscheduledExam(context: currentContext, semesterId: currentSemesterId)
            
            switch unscheduled_exams {
            case .success(let success):
                DispatchQueue.main.async {
                    unscheduledExam = success
                    // 要考试的拍前面
                    unscheduledExam.sort { a, b in
                        let a_prio = (a.examType == "考试" ? 100 : 0)
                        let b_prio = (b.examType == "考试" ? 100 : 0)
                        return a_prio > b_prio
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    GlobalVariables.shared.alertTitle = "无法拉取当前学期未安排的考试"
                    GlobalVariables.shared.alertContent = "可能是网络问题，请检查网络后重试"
                    GlobalVariables.shared.showAlert = true
                }
                return
            }
            
            DispatchQueue.main.async {
                inited = true
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if inited {
                VStack {
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
                                            FetchSemesterInfo(semesterId: choice.title.wrappedValue)
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 10)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.bottom, 10)
                    if !loadingNew {
                        HStack {
                            Text("已安排考试: ")
                                .bold()
                                .font(.system(size: 40))
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        
                        ForEach(arrangedExam, id: \.courseName) { currentExam in
                            ArrangedExamCardView(sideBarColor: .blue, courseName: currentExam.courseName, examType: currentExam.examType, teacherName: currentExam.teacherName, seatNumber: currentExam.seatIndex, examTime: currentExam.examTime, examLocation: currentExam.examLocation)
                        }
                        
                        
                        HStack {
                            Text("未安排考试: ")
                                .bold()
                                .font(.system(size: 40))
                            Spacer()
                        }
                        
                        ForEach(unscheduledExam, id: \.courseName) { currentExam in
                            UnscheduledExamCardView(sideBarColor: .gray, courseName: currentExam.courseName, examType: currentExam.examType, teacherName: currentExam.teacherName)
                        }
                        
                        
                        HStack {
                            Text("已完成考试: ")
                                .bold()
                                .font(.system(size: 40))
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        
                        ForEach(finishedExam, id: \.courseName) { currentExam in
                            ArrangedExamCardView(sideBarColor: .green, courseName: currentExam.courseName, examType: currentExam.examType, teacherName: currentExam.teacherName, seatNumber: currentExam.seatIndex, examTime: currentExam.examTime, examLocation: currentExam.examLocation)
                        }
                        .padding(.bottom, 10)
                        
                    }
                }
                .padding(.horizontal, 10)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Section {
                                Button(action: {
                                    ImportOrUpdateExam()
                                }) {
                                    Label("导入考试到最近事件", systemImage: "square.and.arrow.down")
                                }
                            }
                        }
                    label: {
                        Label("Add", systemImage: "square.and.arrow.down")
                    }
                    }
                }
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .frame(maxWidth: 800)
        .onFirstAppear {
            initExamInfo()
        }
        .navigationTitle("我的考试")
    }
}

#Preview {
    ExamInfoView(semester: [
        .init(title: "2021-2022-1", choose: false),
        .init(title: "2021-2022-2", choose: false),
        .init(title: "2022-2023-1", choose: false),
        .init(title: "2022-2023-2", choose: true)
    ],
                 arrangedExam: [
                    .init(courseName: "控制科学")
    ])
}
