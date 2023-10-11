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
    @State var image_name: String = "figure.highintensity.intervaltraining"
    @State var title: String = "我的成绩"
    @State var content: String = "99分"
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.blue)
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

struct ViewCourseScoreView: View {
    @Binding var currentCourse: Webvpn.ScoreInfo
    
    func StringToFloat(str: String) -> Float {
        return Float(str.filter { "0123456789".contains($0) }) ?? 0
    }
    
    func GetPeopleCount(totPeopleStr: String, progressStr: String) -> (String, String) {
        let totPeopleCount = Int(StringToFloat(str: totPeopleStr))
        let progress = StringToFloat(str: progressStr) / 100.0
        let beforePeople = Int(Float(totPeopleCount) * progress)
        return ("\(beforePeople)人", "\(totPeopleCount - beforePeople)人")
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
                if !currentCourse.my_grade_in_all.isEmpty && !currentCourse.all_study_count.isEmpty {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        VStack {
                            HStack {
                                Text("全部同学中:")
                                    .bold()
                                    .font(.system(size: 30))
                                    .padding(.top, 20)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            ColoredProgressView(progress: Double(StringToFloat(str: currentCourse.my_grade_in_all) / 100.0), beforeText: "\(GetPeopleCount(totPeopleStr: currentCourse.all_study_count, progressStr: currentCourse.my_grade_in_all).0)", afterText: "\(GetPeopleCount(totPeopleStr: currentCourse.all_study_count, progressStr: currentCourse.my_grade_in_all).1)")
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                                .padding(.bottom, 100)
                        }
                    }
                    .shadow(radius: 5)
                }
                if !currentCourse.my_grade_in_major.isEmpty && !currentCourse.major_study_count.isEmpty {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        VStack {
                            HStack {
                                Text("同专业同学中:")
                                    .bold()
                                    .font(.system(size: 30))
                                    .padding(.top, 20)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            ColoredProgressView(progress: Double(StringToFloat(str: currentCourse.my_grade_in_major) / 100.0), beforeText: "\(GetPeopleCount(totPeopleStr: currentCourse.major_study_count, progressStr: currentCourse.my_grade_in_major).0)", afterText: "\(GetPeopleCount(totPeopleStr: currentCourse.major_study_count, progressStr: currentCourse.my_grade_in_major).1)")
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                                .padding(.bottom, 100)
                        }
                    }
                    .shadow(radius: 5)
                }
            }
            .padding(.horizontal)
//            ColoredProgressView()
//                .padding(.horizontal, 20)
//            LightChartView(data: [2, 17, 9, 23, 10],
//                           type: .curved,
//                           visualType: .customFilled(color: .red,
//                                                     lineWidth: 3,
//                                                     fillGradient: LinearGradient(gradient: Gradient(stops: [
//                                                        .init(color: Color.green, location: 0),
//                                                        .init(color: Color.yellow, location: 0.4),
//                                                        .init(color: Color.clear, location: 0.4)
//                                                     ]), startPoint: .leading, endPoint: .trailing)))
        }
        
    }
}


#Preview {
    ViewCourseScoreView(currentCourse: .constant(Webvpn.ScoreInfo(courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")))
}
