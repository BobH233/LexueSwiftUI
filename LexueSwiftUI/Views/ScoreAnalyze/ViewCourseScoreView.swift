//
//  ViewCourseScoreView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/11.
//

import SwiftUI
import LightChart

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

private struct ColoredProgressView: View {
    @State var progress: Double = 0.3
    @State var height: CGFloat = 50
    @State var indicatorColor: Color = .blue
    @State var indicatorSize: CGFloat = 15
    @State var beforeText: String = "10人"
    @State var afterText: String = "20人"
    @State var textVerticalOffset: CGFloat = 25
    @State var textColor: Color = .black
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(gradient: Gradient(stops: [
                        .init(color: Color.green, location: 0),
                        .init(color: Color.yellow, location: 0.6),
                        .init(color: Color.red, location: 0.8)
                    ]), startPoint: .leading, endPoint: .trailing))
                    .frame(height: height)
                Rectangle()
                    .fill(indicatorColor)
                    .frame(width: 3, height: height)
                    .offset(CGSize(width:  -geometry.size.width * 0.5 + geometry.size.width * progress, height: 0))
                Triangle()
                    .fill(indicatorColor)
                    .frame(width: indicatorSize, height: indicatorSize)
                    .rotationEffect(.degrees(0))
                    .offset(CGSize(width:  -geometry.size.width * 0.5 + geometry.size.width * progress, height: (indicatorSize * 0.5 + height * 0.5)))
                Text(beforeText)
                    .foregroundColor(textColor)
                    .shadow(radius: 4)
                    .offset(CGSize(width:  -geometry.size.width * 0.5 + geometry.size.width * progress * 0.5, height: height * 0.5 + textVerticalOffset))
                Text(afterText)
                    .foregroundColor(textColor)
                    .shadow(radius: 4)
                    .offset(CGSize(width:  geometry.size.width * 0.5 - geometry.size.width * (1 - progress) * 0.5, height: height * 0.5 + textVerticalOffset))
            }
            .padding(.bottom, 25)
        }
    }
}

struct SimpleCardView: View {
    @State var color: Color = .blue
    @State var image_name: String = "figure.highintensity.intervaltraining"
    @State var title: String = "我的成绩"
    @State var content: String = "99分"
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
            VStack {
                HStack() {
                    if !image_name.isEmpty {
                        Image(systemName: image_name)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                    }
                    Text(title)
                        .bold()
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                    Spacer()
                }
                .background(.white.opacity(0.2))
                HStack {
                    Text(content)
                        .bold()
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                    Spacer()
                }
            }
        }
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct ContentCardView<Content: View>: View {
    let title: String
    let content: () -> Content
    let color: Color
    init(title0: String, color0: Color, @ViewBuilder content: @escaping () -> Content) {
        self.title = title0
        self.color = color0
        self.content = content
    }
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.white)
            VStack {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size: 30))
                        .padding(.vertical, 20)
                        .padding(.leading, 20)
                    Spacer()
                }
                .background(color)
                content()
            }
        }
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct ViewCourseScoreView: View {
    @Binding var currentCourse: Webvpn.ScoreInfo
    @Binding var allCourses: [Webvpn.ScoreInfo]
    @State var evaluateDiff: Float = 0
    
    func StringToFloat(str: String) -> Float {
        return Float(str.filter { "0123456789".contains($0) }) ?? 0
    }
    
    func GetPeopleCount(totPeopleStr: String, progressStr: String) -> (String, String) {
        let totPeopleCount = Int(StringToFloat(str: totPeopleStr))
        let progress = StringToFloat(str: progressStr) / 100.0
        let beforePeople = Int(Float(totPeopleCount) * progress)
        return ("\(beforePeople)人", "\(totPeopleCount - beforePeople)人")
    }
    
    
    // 评价当前课程对于所有课程均分的影响
    func GetEvaluateResult() -> Float {
        var totCredit: Float = 0
        var totScoreTimesCredit: Float = 0
        var avg_score_without_current: Float = 0
        var avg_score_with_current: Float = 0
        // 先计算一次不计当前课程的均分
        for course in allCourses {
            if course.courseId == currentCourse.courseId {
                continue
            }
            if let credit = Float(course.credit), let score = Float(course.my_score) {
                totCredit = totCredit + credit
                totScoreTimesCredit = totScoreTimesCredit + credit * score
            }
        }
        if totCredit == 0 {
            return 0
        }
        avg_score_without_current = totScoreTimesCredit / totCredit
        avg_score_with_current = avg_score_without_current
        print("不计当前课程平均分: \(avg_score_without_current)")
        if let credit = Float(currentCourse.credit), let score = Float(currentCourse.my_score) {
            totCredit = totCredit + credit
            totScoreTimesCredit = totScoreTimesCredit + credit * score
            avg_score_with_current = totScoreTimesCredit / totCredit
        }
        print("计入当前课程的平均分: \(avg_score_with_current)")
        return avg_score_with_current - avg_score_without_current
    }
    
    var body: some View {
        ScrollView() {
            Text(currentCourse.courseName)
                .bold()
                .multilineTextAlignment(.leading)
                .font(.system(size: 40))
                .padding(.bottom, 10)
            VStack(spacing: 10) {
                if !currentCourse.course_type.isEmpty {
                    SimpleCardView(image_name: "square.split.2x2.fill", title: "课程性质", content: "\(currentCourse.course_type)")
                        .padding(.bottom, 0)
                }
                if !currentCourse.my_score.isEmpty {
                    SimpleCardView(image_name: "star.fill", title: "我的成绩", content: "\(currentCourse.my_score) 分")
                        .padding(.bottom, 0)
                }
                if !currentCourse.credit.isEmpty {
                    SimpleCardView(image_name: "graduationcap.fill", title: "学分", content: "\(currentCourse.credit)")
                        .padding(.bottom, 0)
                }
                if !currentCourse.avg_score.isEmpty {
                    SimpleCardView(image_name: "alternatingcurrent", title: "平均分", content: "\(currentCourse.avg_score) 分")
                        .padding(.bottom, 0)
                }
                if !currentCourse.max_score.isEmpty {
                    SimpleCardView(image_name: "flag.fill", title: "最高分", content: "\(currentCourse.max_score) 分")
                        .padding(.bottom, 0)
                }
                if abs(evaluateDiff) > 0.01 {
                    SimpleCardView(color: evaluateDiff > 0 ? .green : .red, image_name: evaluateDiff > 0 ? "hand.thumbsup.fill" : "hand.thumbsdown.fill", title: evaluateDiff > 0 ? "这门课拉高了平均分" : "这门课拉低了平均分", content: "\(String(format: "%.2f", abs(evaluateDiff))) 分")
                        .padding(.bottom, 0)
                }
                if !currentCourse.my_grade_in_all.isEmpty && !currentCourse.all_study_count.isEmpty {
                    ContentCardView(title0: "全部同学中(前\(currentCourse.my_grade_in_all))", color0: .blue) {
                        ColoredProgressView(progress: Double(StringToFloat(str: currentCourse.my_grade_in_all) / 100.0), beforeText: "\(GetPeopleCount(totPeopleStr: currentCourse.all_study_count, progressStr: currentCourse.my_grade_in_all).0)", afterText: "\(GetPeopleCount(totPeopleStr: currentCourse.all_study_count, progressStr: currentCourse.my_grade_in_all).1)")
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 90)
                    }
                }
                if !currentCourse.my_grade_in_major.isEmpty && !currentCourse.major_study_count.isEmpty {
                    ContentCardView(title0: "同专业同学中(前\(currentCourse.my_grade_in_major))", color0: .blue) {
                        ColoredProgressView(progress: Double(StringToFloat(str: currentCourse.my_grade_in_major) / 100.0), beforeText: "\(GetPeopleCount(totPeopleStr: currentCourse.major_study_count, progressStr: currentCourse.my_grade_in_major).0)", afterText: "\(GetPeopleCount(totPeopleStr: currentCourse.major_study_count, progressStr: currentCourse.my_grade_in_major).1)")
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 90)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            evaluateDiff = GetEvaluateResult()
        }
    }
}


#Preview {
    ViewCourseScoreView(currentCourse: .constant(Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")), allCourses: .constant([
        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用II", credit: "3", my_score: "90", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用III", credit: "3", my_score: "93", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")
    ]))
}
