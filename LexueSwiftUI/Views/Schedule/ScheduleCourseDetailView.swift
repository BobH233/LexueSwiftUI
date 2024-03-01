//
//  ScheduleCourseDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/27.
//

import SwiftUI
import SwiftUICharts

struct ScheduleCourseDetailView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @State var courseObject: JXZXehall.ScheduleCourseInfo =
        .init()
    @State var historyLoaded: Bool = false
    @State var historyScores: [Webvpn.CourseHistoryScoreInfo] = []
    @State var lineChartHistoryData: MultiLineChartData = MultiLineChartData(dataSets: MultiLineDataSet(dataSets: []))
    
    @State var deleteCurrentCourseAlert: Bool = false
    @State var deleteCourseInWeekAlert: Bool  = false
    
    @State var colorSelect: Color = .red
    @State var colorChanged: Int = 0
    
    @State var recommandationSchoolLocation: [SchoolMapManager.SchoolLocationDescription] = []
    
    @Environment(\.dismiss) var dismiss
    
    func generateHistoryChartData(_ originData: [Webvpn.CourseHistoryScoreInfo]) -> MultiLineChartData {
        var points1: [LineChartDataPoint] = []
        var points2: [LineChartDataPoint] = []
        
        var minGrade: Double = 100000
        var maxGrade: Double = 0
        var xAxisLabels: [String] = []
        for history in originData {
            xAxisLabels.append("")
            points1.append(.init(value: history.avg_score))
            points2.append(.init(value: history.max_score, description: history.term))
            minGrade = min(minGrade, history.max_score)
            minGrade = min(minGrade, history.avg_score)
            maxGrade = max(maxGrade, history.max_score)
            maxGrade = max(maxGrade, history.avg_score)
        }
        let dataset1 = LineDataSet(dataPoints: points1, legendTitle: "平均分", pointStyle: PointStyle(borderColour: .black, pointType: .outline, pointShape: .circle), style: LineStyle(lineColour: ColourStyle(colours: [Color.red.opacity(0.90),                                        Color.red.opacity(0.60)],startPoint: .top,endPoint: .bottom)))
        let dataset2 = LineDataSet(dataPoints: points2, legendTitle: "最高分", pointStyle: PointStyle(borderColour: .black, pointType: .outline, pointShape: .square), style: LineStyle(lineColour: ColourStyle(colours: [Color.blue.opacity(0.90),                                        Color.blue.opacity(0.60)],startPoint: .top,endPoint: .bottom)))
        let multi_data = MultiLineDataSet(dataSets: [dataset2, dataset1])
        return MultiLineChartData(dataSets: multi_data, metadata: ChartMetadata(title: "课程成绩历史"), xAxisLabels: xAxisLabels, chartStyle: LineChartStyle(infoBoxPlacement: .floating, markerType: .full(attachment: .point), yAxisTitle: "分数", baseline: .minimumWithMaximum(of: max(Double(minGrade - 5), 0)), topLine: .maximum(of: min(Double(maxGrade + 5), 100))))
    }
    
    func DeleteCurrentCourse() {
        // 只删除这一门课程在这一天的出现
        ScheduleManager.shared.DeleteScheduleCourse(context: managedObjContext, courseId: courseObject.CourseId, deleteOnlySpecDay: courseObject.DayOfWeek)
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name: refreshScheduleListNotification, object: nil)
        }
    }
    
    func DeleteCourseInWeek() {
        // 删除所有课程号所匹配上的这门课程
        ScheduleManager.shared.DeleteScheduleCourse(context: managedObjContext, courseId: courseObject.CourseId, deleteOnlySpecDay: nil)
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name: refreshScheduleListNotification, object: nil)
        }
    }
    
    func UpdateCourseColor(newColor: Color) {
        // 修改课程号匹配的所有课程的颜色
        var to_updates = ScheduleManager.shared.GetAllCourseById(context: managedObjContext, courseId: courseObject.CourseId)
        for to_update in to_updates {
            to_update.color = newColor.toHex()
        }
        DataController.shared.save(context: managedObjContext)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("课程信息") {
                    HStack {
                        Text("课程号")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(courseObject.CourseId)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("课程性质")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(courseObject.CourseType)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("开课学院")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(courseObject.KKDWDM_DISPLAY)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("授课老师")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(courseObject.TeacherName)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("上课校区")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(courseObject.SchoolRegion)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("时间地点")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(courseObject.ClassroomLocationTimeDes)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("学分")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(courseObject.CourseCredit) 分")
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }
                
                Section("导航") {
                    if recommandationSchoolLocation.count == 0 {
                        // Text("暂未适配当前上课地点的导航位置")
                        Text(try! AttributedString(markdown: "暂未适配当前上课地点的导航位置, [点击反馈](https://github.com/BobH233/LexueSwiftUI/issues)"))
                    } else {
                        ForEach(recommandationSchoolLocation.indices, id: \.self) { locationId in
                            Button(action: {
                                SchoolMapManager.shared.OpenMapAppWithLocation(latitude: recommandationSchoolLocation[locationId].latitude, longitude: recommandationSchoolLocation[locationId].longitude, regionDistance: 100, name: recommandationSchoolLocation[locationId].fullName)
                            }) {
                                Label("导航前往 \(recommandationSchoolLocation[locationId].shortName)", systemImage: "figure.walk")
                            }
                        }
                    }
                }
                .onFirstAppear {
                    recommandationSchoolLocation = SchoolMapManager.shared.GenerateRecommandationSchoolLocation(courseLocationDes: courseObject.ClassroomLocationTimeDes, courseRegion: courseObject.SchoolRegion)
                }
                
                Section("操作") {
                    Button("删除 星期\(courseObject.GetDayOfWeekText()) 的这门课程") {
                        VibrateOnce()
                        deleteCurrentCourseAlert = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $deleteCurrentCourseAlert) {
                        Alert(
                            title: Text("删除确认"),
                            message: Text("确认要删除所有周 星期\(courseObject.GetDayOfWeekText()) 的这门课程吗？之后你可以重新从教务导入"),
                            primaryButton: .destructive(Text("确定").foregroundColor(.red)) {
                                DeleteCurrentCourse()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    Button("完全删除这门课程") {
                        VibrateOnce()
                        deleteCourseInWeekAlert = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $deleteCourseInWeekAlert) {
                        Alert(
                            title: Text("删除确认"),
                            message: Text("确认要删除所有周的这门课程吗？之后你可以重新从教务导入"),
                            primaryButton: .destructive(Text("确定").foregroundColor(.red)) {
                                DeleteCourseInWeek()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    ColorPicker("背景色", selection: $colorSelect)
                        .onFirstAppear {
                            colorSelect = courseObject.CourseBgColor
                        }
                        .onChange(of: colorSelect) { newVal in
                            UpdateCourseColor(newColor: newVal)
                            colorChanged += 1
                        }
                }
                
                Section() {
                    if !historyLoaded {
                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                            Spacer()
                        }
                        
                    } else {
                        if historyScores.count == 0 {
                            Text("暂时查询不到历史分数信息")
                        } else if historyScores.count == 1, let record = historyScores.first {
                            // 只有一学期的结果：
                            HStack {
                                Text("记录学期")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(record.term)")
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                            HStack {
                                Text("平均分")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(String(format: "%.2f", record.avg_score))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                            HStack {
                                Text("最高分")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(String(format: "%.2f", record.max_score))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                            HStack {
                                Text("学习人数")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(String(format: "%d", record.student_num))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                        } else {
                            VStack {
                                Text("占位")
                                    .opacity(0.001)
                                MultiLineChart(chartData: lineChartHistoryData)
                                    .touchOverlay(chartData: lineChartHistoryData, specifier: "%.03f", unit: .suffix(of: ""))
                                    .pointMarkers(chartData: lineChartHistoryData)
                                    .xAxisGrid(chartData: lineChartHistoryData)
                                    .yAxisGrid(chartData: lineChartHistoryData)
                                    .xAxisLabels(chartData: lineChartHistoryData)
                                    .yAxisLabels(chartData: lineChartHistoryData)
                                    .floatingInfoBox(chartData: lineChartHistoryData)
                                    .headerBox(chartData: lineChartHistoryData)
                                    .legends(chartData: lineChartHistoryData, columns: [GridItem(.flexible()), GridItem(.flexible())])
                                    .id(lineChartHistoryData.id)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 30)
                            }
                        }
                    }
                } header: {
                    Text("历史成绩信息")
                } footer: {
                    Text("历史信息由BIT101爬取维护")
                }
                .onFirstAppear {
                    Task {
                        let result = await Webvpn.shared.QueryCourseHistoryScoreInfo(courseId: courseObject.CourseId)
                        print(result)
                        DispatchQueue.main.async {
                            lineChartHistoryData = generateHistoryChartData(result)
                            historyScores = result
                            historyLoaded = true
                        }
                    }
                }
            }
            .onDisappear {
                if colorChanged > 1 {
                    NotificationCenter.default.post(name: refreshScheduleListNotification, object: nil)
                }
            }
            .navigationTitle(courseObject.CourseName)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ScheduleCourseDetailView()
}
