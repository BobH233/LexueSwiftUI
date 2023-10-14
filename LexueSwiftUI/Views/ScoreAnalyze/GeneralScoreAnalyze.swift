//
//  GeneralScoreAnalyze.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/11.
//

import SwiftUI

// https://medium.com/@iOSchandra0/how-to-create-a-pie-chart-in-swiftui-c7f056d54c81
struct PieView: View {
    @Binding var slices: [(Double, Color)]
    var body: some View {
        Canvas { context, size in
            // Add these lines to display as Donut
            //Start Donut
            let donut = Path { p in
                p.addEllipse(in: CGRect(origin: .zero, size: size))
                p.addEllipse(in: CGRect(x: size.width * 0.25, y: size.height * 0.25, width: size.width * 0.5, height: size.height * 0.5))
            }
            context.clip(to: donut, style: .init(eoFill: true))
            //End Donut
            let total = slices.reduce(0) { $0 + $1.0 }
            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            var pieContext = context
            pieContext.rotate(by: .degrees(-90))
            let radius = min(size.width, size.height) * 0.48
            let gapSize = Angle(degrees: 5) // size of the gap between slices in degrees
            
            var startAngle = Angle.zero
            for (value, color) in slices {
                if value < 0.001 {
                    continue
                }
                let angle = Angle(degrees: 360 * (value / total))
                let endAngle = startAngle + angle
                let path = Path { p in
                    p.move(to: .zero)
                    p.addArc(center: .zero, radius: radius, startAngle: startAngle + Angle(degrees: 5) / 2, endAngle: endAngle, clockwise: false)
                    p.closeSubpath()
                }
                pieContext.fill(path, with: .color(color))
                startAngle = endAngle
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// 一学期内的数据
class SemesterData {
    var totCredit: Float = 0
    var totScoreTimesCredit: Float = 0
    var gpaCredit: Float = 0
    var sumGpaTimesCredit: Float = 0
    
    func GetAvgTotal() -> Float {
        return totCredit < 0.01 ? 0 : totScoreTimesCredit / totCredit
    }
    
    func GetGpaTotal() -> Float {
        return gpaCredit < 0.01 ? 0 : sumGpaTimesCredit / gpaCredit
    }
    
    func MergeOthers(others: SemesterData) {
        totCredit += others.totCredit
        totScoreTimesCredit += others.totScoreTimesCredit
        gpaCredit += others.gpaCredit
        sumGpaTimesCredit += others.sumGpaTimesCredit
    }
    
    func ConvertToGpa(score: String) -> (Bool, Float) {
        let mp: [String: Float] = [
            "优秀": 4,
            "良好": 3.6,
            "中等": 2.8,
            "及格": 1.7,
            "不及格": 0
        ]
        if let ret = mp[score] {
            return (true, ret)
        }
        if var X = Float(score) {
            if X < 60 {
                X = 0
            }
            if X > 100 {
                return (false, 0)
            }
            return (true, 4 - 3 * (100 - X) * (100 - X) / 1600.0)
        } else {
            return (false, 0)
        }
    }
    
    func AddCourseScore(course: Webvpn.ScoreInfo) {
        if let credit = Float(course.credit), let score = Float(course.my_score) {
            totCredit = totCredit + credit
            totScoreTimesCredit = totScoreTimesCredit + credit * score
        }
        let (success, gpa) = ConvertToGpa(score: course.my_score)
        if let credit = Float(course.credit), success {
            gpaCredit = gpaCredit + credit
            sumGpaTimesCredit = sumGpaTimesCredit + gpa * credit
        }
    }
}

struct GeneralScoreAnalyze: View {
    @Binding var allCourses: [Webvpn.ScoreInfo]
    @State var score_90_cnt: Int = 0
    @State var score_80_cnt: Int = 0
    @State var score_70_cnt: Int = 0
    @State var score_60_cnt: Int = 0
    @State var score_lower_60_cnt: Int = 0
    @State var semestersMap: [String: SemesterData] = [:]
    @State var totalSemesterData = SemesterData()
    
    func GetTotalCountedCourseCnt() -> Int {
        if score_90_cnt + score_80_cnt + score_70_cnt + score_60_cnt + score_lower_60_cnt == 0 {
            return 1
        } else {
            return score_90_cnt + score_80_cnt + score_70_cnt + score_60_cnt + score_lower_60_cnt
        }
    }
    
    func ConvertToGpa(score: String) -> (Bool, Float) {
        let mp: [String: Float] = [
            "优秀": 4,
            "良好": 3.6,
            "中等": 2.8,
            "及格": 1.7,
            "不及格": 0
        ]
        if let ret = mp[score] {
            return (true, ret)
        }
        if var X = Float(score) {
            if X < 60 {
                X = 0
            }
            if X > 100 {
                return (false, 0)
            }
            return (true, 4 - 3 * (100 - X) * (100 - X) / 1600.0)
        } else {
            return (false, 0)
        }
    }
    
    func CalcScoreData() {
        for course in allCourses {
            if let score = Float(course.my_score) {
                if score > 100 {
                    continue
                }
                if score >= 90 {
                    score_90_cnt = score_90_cnt + 1
                } else if score >= 80 {
                    score_80_cnt = score_80_cnt + 1
                } else if score >= 70 {
                    score_70_cnt = score_70_cnt + 1
                } else if score >= 60 {
                    score_60_cnt = score_60_cnt + 1
                } else {
                    score_lower_60_cnt = score_lower_60_cnt + 1
                }
            }
        }
        data.append(contentsOf: [
            (Double(score_90_cnt), Color.green),
            (Double(score_80_cnt), Color.blue),
            (Double(score_70_cnt), Color.orange),
            (Double(score_60_cnt), Color.yellow),
            (Double(score_lower_60_cnt), Color.red),
        ])
        
        for course in allCourses {
            if course.semester.isEmpty {
                continue
            }
            if semestersMap[course.semester] == nil {
                semestersMap[course.semester] = SemesterData()
            }
            semestersMap[course.semester]?.AddCourseScore(course: course)
        }
        
        for semester in semestersMap {
            totalSemesterData.MergeOthers(others: semester.value)
        }
        
    }
    
    @State var data: [(Double, Color)] = []
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ContentCardView(title0: "我的总平均分", color0: .blue) {
                    HStack {
                        Text("\(String(format: "%.2f", totalSemesterData.GetAvgTotal())) 分")
                            .bold()
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding(.bottom, 10)
                            .padding(.leading, 20)
                        Spacer()
                    }
                }
                ContentCardView(title0: "我的总绩点", color0: .blue) {
                    HStack {
                        Text("\(String(format: "%.2f", totalSemesterData.GetGpaTotal())) 分")
                            .bold()
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding(.bottom, 10)
                            .padding(.leading, 20)
                        Spacer()
                    }
                }
                ContentCardView(title0: "已获得总学分", color0: .blue) {
                    HStack {
                        Text("\(String(format: "%.2f", totalSemesterData.totCredit)) 分")
                            .bold()
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding(.bottom, 10)
                            .padding(.leading, 20)
                        Spacer()
                    }
                }
                ContentCardView(title0: "总体概览", color0: .blue) {
                    VStack {
                        PieView(slices: $data)
                            .padding(.horizontal, 20)
                        VStack {
                            if score_90_cnt > 0 {
                                HStack {
                                    Circle()
                                        .foregroundColor(.green)
                                        .frame(width: 15, height: 15)
                                    Text("90-100: \(score_90_cnt)门(\(score_90_cnt * 100 / GetTotalCountedCourseCnt())%)")
                                        .foregroundColor(.black)
                                }
                            }
                            if score_80_cnt > 0 {
                                HStack {
                                    Circle()
                                        .foregroundColor(.blue)
                                        .frame(width: 15, height: 15)
                                    Text("80-89: \(score_80_cnt)门(\(score_80_cnt * 100 / GetTotalCountedCourseCnt())%)")
                                        .foregroundColor(.black)
                                }
                            }
                            if score_70_cnt > 0 {
                                HStack {
                                    Circle()
                                        .foregroundColor(.orange)
                                        .frame(width: 15, height: 15)
                                    Text("70-79: \(score_70_cnt)门(\(score_70_cnt * 100 / GetTotalCountedCourseCnt())%)")
                                        .foregroundColor(.black)
                                }
                            }
                            if score_60_cnt > 0 {
                                HStack {
                                    Circle()
                                        .foregroundColor(.yellow)
                                        .frame(width: 15, height: 15)
                                    Text("60-69: \(score_60_cnt)门(\(score_60_cnt * 100 / GetTotalCountedCourseCnt())%)")
                                        .foregroundColor(.black)
                                }
                            }
                            if score_lower_60_cnt > 0 {
                                HStack {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 15, height: 15)
                                    Text("0-59: \(score_lower_60_cnt)门(\(score_lower_60_cnt * 100 / GetTotalCountedCourseCnt())%)")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.bottom, 15)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onFirstAppear {
            CalcScoreData()
        }
        .navigationTitle("成绩分析")
    }
}

#Preview {
    GeneralScoreAnalyze(allCourses: .constant([
        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用II", credit: "3", my_score: "90", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用III", credit: "3", my_score: "93", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")
    ]))
}
