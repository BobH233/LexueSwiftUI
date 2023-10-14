//
//  GeneralScoreAnalyze.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/11.
//

import SwiftUI

import SwiftUICharts

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
    var semesterName: String = ""
    var totCredit: Float = 0
    var totScoreTimesCredit: Float = 0
    // 这是预估的所有人的平均成绩
    var totAvgCredit: Float = 0
    var totAvgScoreTimesCredit: Float = 0
    var gpaCredit: Float = 0
    var sumGpaTimesCredit: Float = 0
    // 预估所有人的平均gpt
    var gpaAvgCredit: Float = 0
    var sumAvgGpaTimesCredit: Float = 0
    
    func GetMyAvgTotal() -> Float {
        return totCredit < 0.01 ? 0 : totScoreTimesCredit / totCredit
    }
    
    func GetAllAvgTotal() -> Float {
        return totAvgCredit < 0.01 ? 0 : totAvgScoreTimesCredit / totAvgCredit
    }
    
    func GetMyGpaTotal() -> Float {
        return gpaCredit < 0.01 ? 0 : sumGpaTimesCredit / gpaCredit
    }
    
    func GetAllGpaTotal() -> Float {
        return gpaAvgCredit < 0.01 ? 0 : sumAvgGpaTimesCredit / gpaAvgCredit
    }
    
    func MergeOthers(others: SemesterData) {
        totCredit += others.totCredit
        totScoreTimesCredit += others.totScoreTimesCredit
        gpaCredit += others.gpaCredit
        sumGpaTimesCredit += others.sumGpaTimesCredit
        totAvgCredit += others.totAvgCredit
        totAvgScoreTimesCredit += others.totAvgScoreTimesCredit
        gpaAvgCredit += others.gpaAvgCredit
        sumAvgGpaTimesCredit += others.sumAvgGpaTimesCredit
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
        if let X = Float(score) {
            if X < 60 {
                return (true, 0)
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
        if let credit = Float(course.credit), let avg_score = Float(course.avg_score) {
            totAvgCredit = totAvgCredit + credit
            totAvgScoreTimesCredit = totAvgScoreTimesCredit + credit * avg_score
        }
        let (success, gpa) = ConvertToGpa(score: course.my_score)
        if let credit = Float(course.credit), success {
            gpaCredit = gpaCredit + credit
            sumGpaTimesCredit = sumGpaTimesCredit + gpa * credit
        }
        let (success1, gpa1) = ConvertToGpa(score: course.avg_score)
        if let credit = Float(course.credit), success1 {
            gpaAvgCredit = gpaAvgCredit + credit
            sumAvgGpaTimesCredit = sumAvgGpaTimesCredit + gpa1 * credit
        }
    }
}

struct GeneralScoreAnalyze: View {
    @State var shareMode: Bool = false
    @Binding var allCourses: [Webvpn.ScoreInfo]
    @State var score_90_cnt: Int = 0
    @State var score_80_cnt: Int = 0
    @State var score_70_cnt: Int = 0
    @State var score_60_cnt: Int = 0
    @State var score_lower_60_cnt: Int = 0
    @State var semestersMap: [String: SemesterData] = [:]
    @State var semesterArray: [SemesterData] = []
    @State var totalSemesterData = SemesterData()
    @State var lineChartAvgScoreData: MultiLineChartData = MultiLineChartData(dataSets: MultiLineDataSet(dataSets: []))
    @State var lineChartAvgGpaData: MultiLineChartData = MultiLineChartData(dataSets: MultiLineDataSet(dataSets: []))
    
    @State var isActionSheetPresented = false
    @State var displaySize: CGSize = CGSize()
    @State var geometryProxy: GeometryProxy?
    @State var showShareSheet: Bool = false
    @State var showImage: UIImage? = nil
    
    func GetTotalCountedCourseCnt() -> Int {
        if score_90_cnt + score_80_cnt + score_70_cnt + score_60_cnt + score_lower_60_cnt == 0 {
            return 1
        } else {
            return score_90_cnt + score_80_cnt + score_70_cnt + score_60_cnt + score_lower_60_cnt
        }
    }
    
    func generateAvgGpaData(semesterArray: [SemesterData]) -> MultiLineChartData {
        var points1: [LineChartDataPoint] = []
        var points2: [LineChartDataPoint] = []
        var xAxisLabels: [String] = []
        var minGrade: Float = 100000
        var maxGrade: Float = 0
        for semester in semesterArray {
            xAxisLabels.append(semester.semesterName)
            points1.append(.init(value: Double(semester.GetMyGpaTotal()), xAxisLabel: semester.semesterName, description: semester.semesterName))
            points2.append(.init(value: Double(semester.GetAllGpaTotal()), xAxisLabel: semester.semesterName, description: semester.semesterName))
            minGrade = min(minGrade, semester.GetMyGpaTotal())
            minGrade = min(minGrade, semester.GetAllGpaTotal())
            maxGrade = max(maxGrade, semester.GetMyGpaTotal())
            maxGrade = max(maxGrade, semester.GetAllGpaTotal())
        }
        let deltaGrade = maxGrade - minGrade
        let dataset1 = LineDataSet(dataPoints: points1, legendTitle: "我的Gpa", pointStyle: PointStyle(borderColour: .black, pointType: .outline, pointShape: .circle), style: LineStyle(lineColour: ColourStyle(colours: [Color.red.opacity(0.90),                                        Color.red.opacity(0.60)],startPoint: .top,endPoint: .bottom)))
        let dataset2 = LineDataSet(dataPoints: points2, legendTitle: "平均Gpa", pointStyle: PointStyle(borderColour: .black, pointType: .outline, pointShape: .square), style: LineStyle(lineColour: ColourStyle(colours: [Color.blue.opacity(0.90),                                        Color.blue.opacity(0.60)],startPoint: .top,endPoint: .bottom)))
        let multi_data = MultiLineDataSet(dataSets: [dataset1, dataset2])
        return MultiLineChartData(dataSets: multi_data, metadata: ChartMetadata(title: "学期Gpa历史"), xAxisLabels: xAxisLabels, chartStyle: LineChartStyle(infoBoxPlacement: .floating, markerType: .full(attachment: .point), yAxisTitle: "平均分", baseline: .minimumWithMaximum(of: max(Double(minGrade - deltaGrade * 0.1), 0)), topLine: .maximum(of: Double(maxGrade + deltaGrade * 0.1))))
    }
    
    func generateAvgScoreData(semesterArray: [SemesterData]) -> MultiLineChartData {
        var points1: [LineChartDataPoint] = []
        var points2: [LineChartDataPoint] = []
        var xAxisLabels: [String] = []
        var minGrade: Float = 100000
        var maxGrade: Float = 0
        for semester in semesterArray {
            xAxisLabels.append(semester.semesterName)
            points1.append(.init(value: Double(semester.GetMyAvgTotal()), xAxisLabel: semester.semesterName, description: semester.semesterName))
            points2.append(.init(value: Double(semester.GetAllAvgTotal()), xAxisLabel: semester.semesterName, description: semester.semesterName))
            minGrade = min(minGrade, semester.GetMyAvgTotal())
            minGrade = min(minGrade, semester.GetAllAvgTotal())
            maxGrade = max(maxGrade, semester.GetMyAvgTotal())
            maxGrade = max(maxGrade, semester.GetAllAvgTotal())
        }
        
        let dataset1 = LineDataSet(dataPoints: points1, legendTitle: "我的成绩", pointStyle: PointStyle(borderColour: .black, pointType: .outline, pointShape: .circle), style: LineStyle(lineColour: ColourStyle(colours: [Color.red.opacity(0.90),                                        Color.red.opacity(0.60)],startPoint: .top,endPoint: .bottom)))
        let dataset2 = LineDataSet(dataPoints: points2, legendTitle: "平均成绩", pointStyle: PointStyle(borderColour: .black, pointType: .outline, pointShape: .square), style: LineStyle(lineColour: ColourStyle(colours: [Color.blue.opacity(0.90),                                        Color.blue.opacity(0.60)],startPoint: .top,endPoint: .bottom)))
        let multi_data = MultiLineDataSet(dataSets: [dataset1, dataset2])
        return MultiLineChartData(dataSets: multi_data, metadata: ChartMetadata(title: "学期平均绩历史"), xAxisLabels: xAxisLabels, chartStyle: LineChartStyle(infoBoxPlacement: .floating, markerType: .full(attachment: .point), yAxisTitle: "平均分", baseline: .minimumWithMaximum(of: max(Double(minGrade - 5), 0)), topLine: .maximum(of: min(Double(maxGrade + 5), 100))))
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
        PieviewData.append(contentsOf: [
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
                semestersMap[course.semester]?.semesterName = course.semester
            }
            semestersMap[course.semester]?.AddCourseScore(course: course)
        }
        
        for semester in semestersMap {
            totalSemesterData.semesterName = "所有学期"
            totalSemesterData.MergeOthers(others: semester.value)
        }
        semesterArray = Array(semestersMap.values)
        // 按照最近的学期进行排序
        semesterArray.sort { sem1, sem2 in
            return Webvpn.ScoreInfo.SemesterInt(semesterStr: sem1.semesterName) > Webvpn.ScoreInfo.SemesterInt(semesterStr: sem2.semesterName)
        }
        
        lineChartAvgScoreData = generateAvgScoreData(semesterArray: semesterArray.reversed())
        lineChartAvgGpaData = generateAvgGpaData(semesterArray: semesterArray.reversed())
    }
    
    @State var PieviewData: [(Double, Color)] = []
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ContentCardView(title0: "我的总平均分", color0: .blue) {
                    HStack {
                        Text("\(String(format: "%.2f", totalSemesterData.GetMyAvgTotal())) 分")
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
                        Text("\(String(format: "%.2f", totalSemesterData.GetMyGpaTotal())) 分")
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
                        PieView(slices: $PieviewData)
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
                ContentCardView(title0: "各学期平均绩", color0: .blue) {
                    MultiLineChart(chartData: lineChartAvgScoreData)
                        .touchOverlay(chartData: lineChartAvgScoreData, specifier: "%.02f", unit: .suffix(of: " 分"))
                        .pointMarkers(chartData: lineChartAvgScoreData)
                        .xAxisGrid(chartData: lineChartAvgScoreData)
                        .yAxisGrid(chartData: lineChartAvgScoreData)
                        .xAxisLabels(chartData: lineChartAvgScoreData)
                        .yAxisLabels(chartData: lineChartAvgScoreData)
                        .floatingInfoBox(chartData: lineChartAvgScoreData)
                        .headerBox(chartData: lineChartAvgScoreData)
                        .legends(chartData: lineChartAvgScoreData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                        .id(lineChartAvgScoreData.id)
                        .frame(height: 400)
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        .colorScheme(.light)
                }
                .colorScheme(.light)
                ContentCardView(title0: "各学期gpa绩", color0: .blue) {
                    MultiLineChart(chartData: lineChartAvgGpaData)
                        .touchOverlay(chartData: lineChartAvgGpaData, specifier: "%.03f", unit: .suffix(of: ""))
                        .pointMarkers(chartData: lineChartAvgGpaData)
                        .xAxisGrid(chartData: lineChartAvgGpaData)
                        .yAxisGrid(chartData: lineChartAvgGpaData)
                        .xAxisLabels(chartData: lineChartAvgGpaData)
                        .yAxisLabels(chartData: lineChartAvgGpaData)
                        .floatingInfoBox(chartData: lineChartAvgGpaData)
                        .headerBox(chartData: lineChartAvgGpaData)
                        .legends(chartData: lineChartAvgGpaData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                        .id(lineChartAvgGpaData.id)
                        .frame(height: 400)
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        .colorScheme(.light)
                }
                .colorScheme(.light)
                Color
                    .clear
                    .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    geometryProxy = proxy
                    print(proxy.size.height)
                    displaySize = proxy.size
                }
            }
        )
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
                    currentSize.height += 60
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
                    currentSize.height += 60
                    let result = self.body.snapshot(size: currentSize)
                    shareMode = false
                    showImage = result
                    DispatchQueue.main.async {
                        showShareSheet = true
                    }
                },
                .cancel(Text("取消"))
            ])
        }
        .navigationBarItems(trailing:
                                Button(action: {
            self.isActionSheetPresented.toggle()
        }) {
            Image(systemName: "square.and.arrow.up")
        }
        )
        .onFirstAppear {
            CalcScoreData()
        }
        .navigationTitle("成绩分析")
    }
}

#Preview {
    GeneralScoreAnalyze(allCourses: .constant([
        Webvpn.ScoreInfo(semester: "2013-2014-1", courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(semester: "2013-2014-1", courseName: "控制科学基本原理与应用II", credit: "3", my_score: "90", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(semester: "2013-2014-1", courseName: "控制科学基本原理与应用III", credit: "3", my_score: "93", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(semester: "2013-2014-2", courseName: "控制科学基本原理与应用I", credit: "3", my_score: "81", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(semester: "2013-2014-2", courseName: "控制科学基本原理与应用II", credit: "3", my_score: "89", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100"),
        Webvpn.ScoreInfo(semester: "2013-2014-2", courseName: "控制科学基本原理与应用III", credit: "3", my_score: "79", my_grade_in_major: "80%", my_grade_in_all: "83%", all_study_count: "80", major_study_count: "44", avg_score: "87.9", max_score: "100")
    ]))
}
