//
//  ViewCourseScoreView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/11.
//

import SwiftUI

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
    @Environment(\.colorScheme) var sysColorScheme
    let title: String
    let content: () -> Content
    let color: Color
    let forceWhite: Bool
    init(title0: String, color0: Color, forceWhite: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title0
        self.color = color0
        self.content = content
        self.forceWhite = forceWhite
    }
    var body: some View {
        ZStack{
            if forceWhite {
                Rectangle()
                    .foregroundColor(.white)
            } else {
                Rectangle()
                    .foregroundColor(sysColorScheme == .light ? .white : .secondarySystemBackground)
            }
            
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

struct LogoAdView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image("app_download_code")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .border(.black)
                Text("使用 \"i乐学助手\" 生成")
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
        }
    }
}

struct ViewCourseScoreView: View {
    @Binding var currentCourse: Webvpn.ScoreInfo
    @Binding var allCourses: [Webvpn.ScoreInfo]
    @State var evaluateDiff: Float = 0
    @State private var isActionSheetPresented = false
    @Environment(\.colorScheme) var sysColorScheme
    
    
    @State var shareMode: Bool = false
    
    @State var displaySize: CGSize = CGSize()
    @State var geometryProxy: GeometryProxy?
    
    @State var showShareSheet: Bool = false
    @State var showImage: UIImage? = nil
    
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
            ZStack {
                VStack(spacing: 10) {
                    Text(currentCourse.courseName)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(shareMode ? .black : (sysColorScheme == .dark ? .white : .black))
                        .font(.system(size: 40))
                        .padding(.bottom, 10)
                    
                    if !currentCourse.semester.isEmpty {
                        SimpleCardView(image_name: "microbe.fill", title: "开课学期", content: "\(currentCourse.semester)")
                            .padding(.bottom, 0)
                    }
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
                        ContentCardView(title0: "全部同学中(前\(currentCourse.my_grade_in_all))", color0: .blue, forceWhite: true) {
                            ColoredProgressView(progress: Double(StringToFloat(str: currentCourse.my_grade_in_all) / 100.0), beforeText: "\(GetPeopleCount(totPeopleStr: currentCourse.all_study_count, progressStr: currentCourse.my_grade_in_all).0)", afterText: "\(GetPeopleCount(totPeopleStr: currentCourse.all_study_count, progressStr: currentCourse.my_grade_in_all).1)")
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                                .padding(.bottom, 90)
                        }
                    }
                    if !currentCourse.my_grade_in_major.isEmpty && !currentCourse.major_study_count.isEmpty {
                        ContentCardView(title0: "同专业同学中(前\(currentCourse.my_grade_in_major))", color0: .blue, forceWhite: true) {
                            ColoredProgressView(progress: Double(StringToFloat(str: currentCourse.my_grade_in_major) / 100.0), beforeText: "\(GetPeopleCount(totPeopleStr: currentCourse.major_study_count, progressStr: currentCourse.my_grade_in_major).0)", afterText: "\(GetPeopleCount(totPeopleStr: currentCourse.major_study_count, progressStr: currentCourse.my_grade_in_major).1)")
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                                .padding(.bottom, 90)
                        }
                    }
                    if shareMode {
                        Divider()
                        LogoAdView()
                    }
                    // 补齐底部
                    Color
                        .clear
                        .padding(.bottom, 20)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            geometryProxy = proxy
                            displaySize = proxy.size
                        }
                    }
                )
                .frame(maxWidth: 500)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(photo: showImage, text: "\(currentCourse.courseName) 课程的成绩单")
        }
        .background(shareMode ? .white : .clear)
        .navigationBarItems(trailing:
                                Button(action: {
            self.isActionSheetPresented.toggle()
        }) {
            Image(systemName: "square.and.arrow.up")
        }
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(title: Text("选项"), buttons: [
                    .default(Text("保存成绩单图片")) {
                        if geometryProxy == nil {
                            GlobalVariables.shared.alertTitle = "无法导出成绩单"
                            GlobalVariables.shared.alertContent = "无法读取页面大小，请重试"
                            GlobalVariables.shared.showAlert = true
                            return
                        }
                        shareMode = true
                        var currentSize = geometryProxy!.size
                        currentSize.height += 130
                        let result = self.body.snapshot(size: currentSize)
                        shareMode = false
                        UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
                        GlobalVariables.shared.alertTitle = "成功导出成绩单"
                        GlobalVariables.shared.alertContent = "请在你的照片中查看"
                        GlobalVariables.shared.showAlert = true
                    },
                    .default(Text("分享成绩单图片")) {
                        if geometryProxy == nil {
                            GlobalVariables.shared.alertTitle = "无法导出成绩单"
                            GlobalVariables.shared.alertContent = "无法读取页面大小，请重试"
                            GlobalVariables.shared.showAlert = true
                            return
                        }
                        shareMode = true
                        var currentSize = geometryProxy!.size
                        currentSize.height += 130
                        let result = self.body.snapshot(size: currentSize)
                        shareMode = false
                        showImage = result
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showShareSheet = true
                        }
                    },
                    .cancel(Text("取消"))
                ])
            }
        )
        .onFirstAppear {
            evaluateDiff = GetEvaluateResult()
        }
    }
}


#Preview {
    LogoAdView()
//    ViewCourseScoreView(currentCourse: .constant(Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")), allCourses: .constant([
//        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
//        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用II", credit: "3", my_score: "90", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
//        Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用III", credit: "3", my_score: "93", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")
//    ]))
}
