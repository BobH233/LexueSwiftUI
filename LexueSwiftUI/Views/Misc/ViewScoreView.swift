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
            NavigationLink("成绩分析", destination: GeneralScoreAnalyze(allCourses: $scoreInfo))
                .isDetailLink(false)
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
    private func row(course: Webvpn.ScoreInfo) -> some View {
        ZStack {
            LazyVGrid(columns: gridItems) {
                Text(course.index)
                Text(course.courseName)
                Text(course.my_score)
                Text(course.credit)
                Text(course.avg_score)
                Text(course.max_score)
                Text(course.my_grade_in_all)
                Text(course.my_grade_in_major)
                Text(course.semester)
                Text(course.course_type)
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
                .scaleEffect(2)
                .onAppear {
                    Task {
                        let login_res = await Webvpn.shared.GetWebvpnContext(username: SettingStorage.shared.savedUsername, password: SettingStorage.shared.savedPassword)
                        switch login_res {
                        case .success(let context):
                            let score_res = await Webvpn.shared.QueryScoreInfo(webvpn_context: context)
                            switch score_res {
                            case .success(let ret_scoreInfo):
                                DispatchQueue.main.async {
                                    scoreInfo = ret_scoreInfo.reversed()
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
        } else {
            TablerList(header: header,
                       row: row,
                       results: scoreInfo)
            .sideways(minWidth: 1200, showIndicators: true)
            .background(Color.secondarySystemBackground)
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
