//
//  ViewScoreView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/10.
//

import SwiftUI
import Tabler
import Sideways

// 成绩查询页面

struct ViewScoreView: View {
    @State var scoreInfo = [Webvpn.ScoreInfo]()
    @State var loadingData = true
    @State var errorLoading = false
    @State var showDetailView: Bool = false
    @State var showDetailCourse = Webvpn.ScoreInfo()
    @State var showFilterSheet: Bool = false
    
    @State var course_type_choices: [FilterOptionBool] = []
    @State var semester_type_choices: [FilterOptionBool] = []
    
    let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 当前列表显示中的优良率
    @State var current_rate80: Float = 0
    // 当期列表中显示的平均分
    @State var current_avgScore: Float = 0
    // 当前列表中显示的gpa
    @State var current_avgGPA: Float = 0
    // 当前列表中显示的门数
    @State var current_courseCount: Int = 0
    
    private func CalcCurrentStatistics() {
        var tmpCount: Float = 0
        var tmpUpperEqual80: Float = 0
        var totalScoreTimesCredit: Float = 0
        var totalCredit: Float = 0
        var totalGpaTimesCredit: Float = 0
        current_courseCount = 0
        for score in scoreInfo {
            if !FilterScoreInfo(current: score) {
                continue
            }
            // 过滤掉忽略的课程
            if score.ignored_course {
                continue
            }
            current_courseCount += 1
            guard let score_float = Float(score.my_score) else {
                continue
            }
            guard let credit_float = Float(score.credit) else {
                continue
            }
            totalCredit += credit_float
            let (result, gpa) = SemesterData.ConvertToGpa(score: score.my_score)
            tmpCount += 1
            if score_float >= 80 {
                tmpUpperEqual80 += 1
            }
            totalScoreTimesCredit += score_float * credit_float
            if result {
                totalGpaTimesCredit += gpa * credit_float
            }
        }
        current_rate80 = tmpUpperEqual80 / tmpCount
        current_avgScore = totalScoreTimesCredit / totalCredit
        current_avgGPA = totalGpaTimesCredit / totalCredit
    }
    
    private var gridItems: [GridItem] = [
        // 序号
        GridItem(.fixed(70), alignment: .leading),
        // 课程名
        GridItem(.fixed(150), alignment: .leading),
        // 我的成绩
        GridItem(.fixed(70), alignment: .leading),
        // 学分
        GridItem(.fixed(70), alignment: .leading),
        // 平均分
        GridItem(.fixed(70), alignment: .leading),
        // 最高分
        GridItem(.fixed(70), alignment: .leading),
        // 全部排名
        GridItem(.fixed(70), alignment: .leading),
        // 专业排名
        GridItem(.fixed(70), alignment: .leading),
        // 开课学期
        GridItem(.fixed(150), alignment: .leading),
        // 课程性质
        GridItem(.fixed(150), alignment: .leading),
    ]
    private typealias Context = TablerContext<Webvpn.ScoreInfo>
    private typealias Sort = TablerSort<Webvpn.ScoreInfo>
    
    private func header(ctx: Binding<Context>) -> some View {
        Group {
            LazyVGrid(columns: gridItems) {
                Sort.columnTitle("序号", ctx, \.index)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.index) {
                            let index1: Int = Int($0.index) ?? 0
                            let index2: Int = Int($1.index) ?? 0
                            return index1 < index2
                        }
                    }
                Sort.columnTitle("课程名称", ctx, \.courseName)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.courseName) {
                            return $0.courseName < $1.courseName
                        }
                    }
                Sort.columnTitle("我的成绩", ctx, \.my_score)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.my_score) {
                            let score1: Float = Float($0.my_score) ?? 0
                            let score2: Float = Float($1.my_score) ?? 0
                            return score1 < score2
                        }
                    }
                Sort.columnTitle("学分", ctx, \.credit)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.credit) {
                            let credit1: Float = Float($0.credit) ?? 0
                            let credit2: Float = Float($1.credit) ?? 0
                            return credit1 < credit2
                        }
                    }
                Sort.columnTitle("平均分", ctx, \.avg_score)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.avg_score) {
                            let avg1: Float = Float($0.avg_score) ?? 0
                            let avg2: Float = Float($1.avg_score) ?? 0
                            return avg1 < avg2
                        }
                    }
                Sort.columnTitle("最高分", ctx, \.max_score)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.max_score) {
                            let max1: Float = Float($0.max_score) ?? 0
                            let max2: Float = Float($1.max_score) ?? 0
                            return max1 < max2
                        }
                    }
                Sort.columnTitle("全部排名", ctx, \.my_grade_in_all)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.my_grade_in_all) {
                            let num1: Float = Float($0.my_grade_in_all.filter { "0123456789".contains($0) }) ?? 0
                            let num2: Float = Float($1.my_grade_in_all.filter { "0123456789".contains($0) }) ?? 0
                            return num1 < num2
                        }
                    }
                Sort.columnTitle("专业排名", ctx, \.my_grade_in_major)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.my_grade_in_major) {
                            let num1: Float = Float($0.my_grade_in_major.filter { "0123456789".contains($0) }) ?? 0
                            let num2: Float = Float($1.my_grade_in_major.filter { "0123456789".contains($0) }) ?? 0
                            return num1 < num2
                        }
                    }
                Sort.columnTitle("开课学期", ctx, \.semester)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.semester) {
                            let convertSemester: (String) -> Int = { semeStr in
                                let segments = semeStr.split(separator: "-")
                                if segments.count != 3 {
                                    return 0
                                }
                                let first: Int = Int(segments[0]) ?? 0
                                let second: Int = Int(segments[1]) ?? 0
                                let third: Int = Int(segments[2]) ?? 0
                                return first * 100000 + second * 10 + third
                            }
                            return convertSemester($0.semester) < convertSemester($1.semester)
                        }
                    }
                Sort.columnTitle("课程性质", ctx, \.course_type)
                    .onTapGesture {
                        tablerSort(ctx, &scoreInfo, \.course_type) {
                            return $0.course_type < $1.course_type
                        }
                    }
            }
        }
    }
    
    func LoadFilterOptions() {
        var courseTypeSet = Set<String>()
        var semesterSet = Set<String>()
        for courseInfo in scoreInfo {
            if !courseInfo.course_type.isEmpty {
                courseTypeSet.insert(courseInfo.course_type)
            }
            if !courseInfo.semester.isEmpty {
                semesterSet.insert(courseInfo.semester)
            }
        }
        for courseType in courseTypeSet {
            course_type_choices.append(.init(title: courseType, choose: true))
        }
        for semester in semesterSet {
            semester_type_choices.append(.init(title: semester, choose: true))
        }
        semester_type_choices.sort { option1, option2 in
            return Webvpn.ScoreInfo.SemesterInt(semesterStr: option1.title) > Webvpn.ScoreInfo.SemesterInt(semesterStr: option2.title)
        }
    }
    
    func ProcessResitSituation(_ score_res: [Webvpn.ScoreInfo]) -> [Webvpn.ScoreInfo] {
        // 处理补考的相关情况，取分数最高的一次作为最后取用的结果
        var couseIdToIndex: [String: [Int]] = [:]
        var ret = score_res
        for (index, score) in score_res.enumerated() {
            if couseIdToIndex[score.courseId] == nil {
                couseIdToIndex[score.courseId] = [index]
            } else {
                couseIdToIndex[score.courseId]!.append(index)
            }
        }
        for (_, value) in couseIdToIndex {
            var hasResit = false
            for courseIndex in value {
                if score_res[courseIndex].exam_type == "补考" || score_res[courseIndex].exam_type == "重考" {
                    hasResit = true
                    break
                }
            }
            if !hasResit {
                continue
            }
            var maxScore = 0
            for courseIndex in value {
                maxScore = max(maxScore, Int(score_res[courseIndex].my_score) ?? 0)
                ret[courseIndex].ignored_course = true
            }
            for courseIndex in value {
                var curScore = Int(score_res[courseIndex].my_score) ?? 0
                if curScore == maxScore {
                    ret[courseIndex].ignored_course = false
                    break
                }
            }
        }
        return ret
    }
    
    func LoadScoresInfo(tryCache: Bool = true) {
        if tryCache && SettingStorage.shared.cache_webvpn_context != "" && SettingStorage.shared.cache_webvpn_context_for_user == GlobalVariables.shared.cur_user_info.stuId {
            // 有缓存，先尝试缓存
            print("Hit Cache, try cache loading score...")
            Task {
                var context = Webvpn.WebvpnContext(wengine_vpn_ticketwebvpn_bit_edu_cn: SettingStorage.shared.cache_webvpn_context)
                var score_res = await Webvpn.shared.QueryScoreInfo(webvpn_context: context)
                switch score_res {
                case .success(let ret_scoreInfo):
                    DispatchQueue.main.async {
                        scoreInfo = ProcessResitSituation(ret_scoreInfo).reversed()
                        LoadFilterOptions()
                        loadingData = false
                        DispatchQueue.main.async {
                            CalcCurrentStatistics()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            CalcCurrentStatistics()
                        }
                    }
                case .failure(_):
                    LoadScoresInfo(tryCache: false)
                }
            }
        } else {
            Task {
                let login_res = await Webvpn.shared.GetWebvpnContext(username: SettingStorage.shared.savedUsername, password: SettingStorage.shared.savedPassword)
                switch login_res {
                case .success(let context):
                    DispatchQueue.main.async {
                        SettingStorage.shared.cache_webvpn_context = context.wengine_vpn_ticketwebvpn_bit_edu_cn
                        SettingStorage.shared.cache_webvpn_context_for_user = GlobalVariables.shared.cur_user_info.stuId
                    }
                    let score_res = await Webvpn.shared.QueryScoreInfo(webvpn_context: context)
                    switch score_res {
                    case .success(let ret_scoreInfo):
                        DispatchQueue.main.async {
                            scoreInfo = ProcessResitSituation(ret_scoreInfo).reversed()
                            LoadFilterOptions()
                            loadingData = false
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            errorLoading = true
                            loadingData = false
                            GlobalVariables.shared.alertTitle = "获取成绩失败"
                            GlobalVariables.shared.alertContent = "这可能是网络问题，请确保你的账户目前能够正常登录"
                            GlobalVariables.shared.showAlert = true
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        errorLoading = true
                        loadingData = false
                        GlobalVariables.shared.alertTitle = "自动登录Webvpn失败"
                        GlobalVariables.shared.alertContent = "这可能是网络问题，请确保你的账户目前能够正常登录"
                        GlobalVariables.shared.showAlert = true
                    }
                }
            }
        }
    }
    
    func FilterScoreInfo(current: Webvpn.ScoreInfo) -> Bool {
        // 过滤学期
        for semester_type_choice in semester_type_choices {
            if semester_type_choice.title == current.semester && !semester_type_choice.choose {
                return false
            }
        }
        // 过滤课程类型
        for couse_type_choice in course_type_choices {
            if couse_type_choice.title == current.course_type && !couse_type_choice.choose {
                return false
            }
        }
        return true
    }
    
    private func row(course: Webvpn.ScoreInfo) -> some View {
        ZStack {
            LazyVGrid(columns: gridItems) {
                if course.exam_type == "补考" || course.exam_type == "重考" {
                    Group {
                        Text(course.index)
                            .strikethrough(course.ignored_course)
                        Text("\(course.courseName) (\(course.exam_type))")
                            .strikethrough(course.ignored_course)
                        Text(course.my_score)
                            .strikethrough(course.ignored_course)
                        Text(course.credit)
                            .strikethrough(course.ignored_course)
                        Text(course.avg_score)
                            .strikethrough(course.ignored_course)
                        Text(course.max_score)
                            .strikethrough(course.ignored_course)
                        Text(course.my_grade_in_all)
                            .strikethrough(course.ignored_course)
                        Text(course.my_grade_in_major)
                            .strikethrough(course.ignored_course)
                        Text(course.semester)
                            .strikethrough(course.ignored_course)
                        Text(course.course_type)
                            .strikethrough(course.ignored_course)
                    }
                    .foregroundColor(.green)
                } else {
                    Text(course.index)
                        .strikethrough(course.ignored_course)
                    Text(course.courseName)
                        .strikethrough(course.ignored_course)
                    Text(course.my_score)
                        .strikethrough(course.ignored_course)
                    Text(course.credit)
                        .strikethrough(course.ignored_course)
                    Text(course.avg_score)
                        .strikethrough(course.ignored_course)
                    Text(course.max_score)
                        .strikethrough(course.ignored_course)
                    Text(course.my_grade_in_all)
                        .strikethrough(course.ignored_course)
                    Text(course.my_grade_in_major)
                        .strikethrough(course.ignored_course)
                    Text(course.semester)
                        .strikethrough(course.ignored_course)
                    Text(course.course_type)
                        .strikethrough(course.ignored_course)
                }
            }
            Rectangle()
                .foregroundColor(.white.opacity(0.01))
        }
        .onTapGesture {
            print(course)
            showDetailCourse = course
            showDetailView = true
        }
    }
    var body: some View {
        if errorLoading {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("加载出错")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                    Spacer()
                }
                Spacer()
            }
        } else if loadingData {
            ProgressView()
                .controlSize(.large)
                .onAppear {
                    LoadScoresInfo()
                }
        } else if scoreInfo.count == 0 {
            Text("你还没有成绩信息哦~")
        } else {
            HStack {
                NavigationLink(destination: GeneralScoreAnalyze(allCourses: $scoreInfo)) {
                    Text("详细成绩分析")
                        .padding(.top, 10)
                        .padding(.leading, 20)
                }
                .isDetailLink(false)
                Spacer()
            }
            HStack {
                Button(action: {
                    showFilterSheet = true
                }, label: {
                    Text("显示过滤")
                        .padding(.top, 10)
                        .padding(.leading, 20)
                })
                Spacer()
            }
            .sheet(isPresented: $showFilterSheet, content: {
                FilterScoreView(couse_type_choices: $course_type_choices, semester_type_choices: $semester_type_choices)
            })
            HStack {
                VStack(spacing: 10) {
                    HStack {
                        Text("当前门数:")
                            .bold()
                        Text("\(current_courseCount)")
                        Spacer()
                    }
                    HStack {
                        Text("当前优良率:")
                            .bold()
                        Text("\(String(format: "%.2f", current_rate80 * 100))%")
                        Spacer()
                    }
                    HStack {
                        Text("当前平均分:")
                            .bold()
                        Text("\(String(format: "%.2f", current_avgScore))")
                        Text("当前平均GPA:")
                            .bold()
                        Text("\(String(format: "%.2f", current_avgGPA))")
                        Spacer()
                    }
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                Spacer()
            }
            .onReceive(refreshTimer) { _ in
                // print("定时刷新成绩统计信息")
                CalcCurrentStatistics()
            }
            HStack {
                Text("左右拖动列表可以查看更多信息")
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                    .padding(.leading, 20)
                Spacer()
            }
            TablerList(.init(filter: FilterScoreInfo), header: header,
                       row: row,
                       results: scoreInfo)
            .sideways(minWidth: 1200, showIndicators: true)
            .background(Color.secondarySystemBackground)
            .onChange(of: course_type_choices) { newVal in
                CalcCurrentStatistics()
            }
            .onChange(of: semester_type_choices) { newVal in
                CalcCurrentStatistics()
            }
            .navigationTitle("成绩查询")
            NavigationLink("", destination: ViewCourseScoreView(currentCourse: $showDetailCourse, allCourses: $scoreInfo), isActive: $showDetailView)
                .isDetailLink(false)
                .hidden()
            
        }
    }
}

#Preview {
    ViewScoreView()
}
