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

struct ScoreInfo: Identifiable, Hashable {
    var id: String {
        return courseId
    }
    
    // 开课学期
    var semester: String = ""
    // 课程编号
    var courseId: String = ""
    // 课程名称
    var courseName: String = ""
    // 学分
    var credit: String = ""
    // 总学时
    var study_hours: String = ""
    // 课程性质
    var course_type: String = ""
    // 本人成绩
    var my_score: String = ""
    // 专业排名
    var my_grade_in_major: String = ""
    // 班级排名
    var my_grade_in_class: String = ""
    // 全部排名
    var my_grade_in_all: String = ""
    // 班级人数
    var class_study_count: String = ""
    // 学习人数
    var all_study_count: String = ""
    // 专业人数
    var major_study_count: String = ""
    // 平均分
    var avg_score: String = ""
    // 最高分
    var max_score: String = ""
}

func LoadDemoScoreInfo() -> [ScoreInfo] {
    return [
        .init(semester: "12345-1234", courseId: "114514", courseName: "课程名字课程名字课程名字课程名字课程名字", credit: "4", study_hours: "64",course_type: "公选课", my_score: "99", my_grade_in_all: "12%"),
        .init(semester: "12345-1234", courseId: "1234", courseName: "课程名字1", credit: "1", study_hours: "64",course_type: "公选课", my_score: "91" , my_grade_in_all: "19%"),
        .init(semester: "12345-1234", courseId: "32123", courseName: "课程名字2", credit: "5", study_hours: "64",course_type: "公选课", my_score: "92" , my_grade_in_all: "30%"),
        .init(semester: "12345-1234", courseId: "12313123", courseName: "课程名字3", credit: "8", study_hours: "64",course_type: "公选课", my_score: "94" , my_grade_in_all: "15%"),
        .init(semester: "12345-1234", courseId: "33333", courseName: "课程名字4", credit: "4", study_hours: "64",course_type: "公选课", my_score: "91" , my_grade_in_all: "14%")
    ]
}

struct ViewScoreView: View {
    @State var scoreInfo = [ScoreInfo]()
    private var gridItems: [GridItem] = [
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
    private typealias Context = TablerContext<ScoreInfo>
    private typealias Sort = TablerSort<ScoreInfo>
    
    private func header(ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems) {
            Sort.columnTitle("课程名称", ctx, \.courseName)
                .onTapGesture {
                    tablerSort(ctx, &scoreInfo, \.courseName) {
                        return $0.courseName < $1.courseName
                    }
                }
            Sort.columnTitle("我的成绩", ctx, \.my_score)
                .onTapGesture {
                    tablerSort(ctx, &scoreInfo, \.my_score) {
                        let score1: Int = Int($0.my_score) ?? 0
                        let score2: Int = Int($1.my_score) ?? 0
                        return score1 < score2
                    }
                }
            Sort.columnTitle("学分", ctx, \.credit)
                .onTapGesture {
                    tablerSort(ctx, &scoreInfo, \.credit) {
                        let credit1: Int = Int($0.credit) ?? 0
                        let credit2: Int = Int($1.credit) ?? 0
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
    private func row(course: ScoreInfo) -> some View {
        LazyVGrid(columns: gridItems) {
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
    }
    var body: some View {
        TablerList(header: header,
                   row: row,
                   results: scoreInfo)
        .sideways(minWidth: 1000, showIndicators: true)
        .background(Color.secondarySystemBackground)
        .onAppear {
            scoreInfo = LoadDemoScoreInfo()
        }
    }
}

#Preview {
    ViewScoreView()
}
