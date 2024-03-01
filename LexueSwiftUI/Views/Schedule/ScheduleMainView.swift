//
//  ScheduleMainView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/23.
//

import SwiftUI

// 每一周的课程表安排
struct WeeklyScheduleView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    
    func chooseTextColor(_ backgroundColor: UIColor) -> Color {
        // 计算背景颜色的亮度
        let red = backgroundColor.cgColor.components?[0] ?? 0
        let green = backgroundColor.cgColor.components?[1] ?? 0
        let blue = backgroundColor.cgColor.components?[2] ?? 0
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        // 根据背景颜色亮度选择前景文字颜色
        if brightness < 0.7 {
            return .white
        } else {
            return .black
        }
    }
    
    // 定义常量用于设定单个课程的高度
    let UnitBlockHeight: Float = 80
    
    @State var weekIndex: Int
    
    // 星期文本
    @State var weekTextArr: [String] = [
        "一",
        "二",
        "三",
        "四",
        "五",
        "六",
        "日"
    ]
    // 星期n对应的是几号
    @Binding var dateDayArr: [String]
    @Binding var dateDayDateArr: [Date]
    
    @Binding var sectionInfo: [ScheduleSectionInfo]
    
    @Binding var firstDate: Date
    @Binding var currentMonth: String
    
    
    // 每天的课程
//    @State var dailyCourses: [DailyScheduleInfo] = [
//        .init(day_index: 1, courses_today: [
//            .init(CourseName: "会员制餐厅导论", TeacherName: "醇平", ClassroomLocation:"会员制餐厅", StartSectionId: 1, EndSectionId: 2, CourseBgColor: .brown),
//            .init(CourseName: "如何赚钱", TeacherName: "申家芮", ClassroomLocation:"北京良乡看守所", StartSectionId: 5, EndSectionId: 8, CourseBgColor: .yellow),
//        ]),
//        .init(day_index: 2, courses_today: []),
//        .init(day_index: 3, courses_today: [
//            .init(CourseName: "数据结构与编曲", TeacherName: "泽野螳螂", ClassroomLocation:"Bilibili", StartSectionId: 3, EndSectionId: 5),
//            .init(CourseName: "哲学与人生", TeacherName: "VanSama", ClassroomLocation:"博雅更衣室", StartSectionId: 6, EndSectionId: 7, CourseBgColor: .pink),
//        ]),
//        .init(day_index: 4, courses_today: []),
//        .init(day_index: 5, courses_today: []),
//        .init(day_index: 6, courses_today: []),
//        .init(day_index: 7, courses_today: []),
//    ]
    
    @Binding var dailyCourses: [DailyScheduleInfo]
    func GetCourseBlockHeight(_ course: JXZXehall.ScheduleCourseInfo) -> CGFloat {
        let height: Float = (UnitBlockHeight + 3.0) * Float(course.GetSectionLength()) - 3.0
        return CGFloat(height)
    }
    
    @State var showDetailSheet: Bool = false
    @State var detailSheetCourse: JXZXehall.ScheduleCourseInfo = .init()
    
    var body: some View {
        // 抬头不可滚动栏，写日期
        VStack {
            HStack(spacing: 0) {
                Text(currentMonth)
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                ForEach(Array(weekTextArr.enumerated()), id: \.element) { index, element in
                    if compareDatesIgnoringTime(dateDayDateArr[index], .now) == .orderedSame {
                        VStack {
                            Text(element)
                                .bold()
                            Text(dateDayArr[index])
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    } else {
                        VStack {
                            Text(element)
                            Text(dateDayArr[index])
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 10)
            ScrollView(.vertical) {
                HStack(spacing: 2) {
                    // 显示每节课上下课信息列
                    VStack(spacing: 3) {
                        ForEach(sectionInfo, id: \.sectionIndex) { curSection in
                            if curSection.GetIsDateInSection() {
                                VStack {
                                    Text("\(curSection.sectionIndex)")
                                        .bold()
                                        .font(.system(size: 15))
                                    Text("\(curSection.sectionStartDateStr)")
                                        .bold()
                                        .font(.system(size: 12))
                                    Text("\(curSection.sectionEndDateStr)")
                                        .bold()
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.blue)
                                .frame(height: CGFloat(UnitBlockHeight))
                            } else {
                                VStack {
                                    Text("\(curSection.sectionIndex)")
                                        .font(.system(size: 15))
                                        .bold()
                                    Text("\(curSection.sectionStartDateStr)")
                                        .font(.system(size: 12))
                                    Text("\(curSection.sectionEndDateStr)")
                                        .font(.system(size: 12))
                                }
                                .frame(height: CGFloat(UnitBlockHeight))
                            }
                            // .background(.red)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    // .background(.green)
                    ForEach(dailyCourses, id: \.day_index) { today_courses in
                        VStack(spacing: 3) {
                            ForEach(sectionInfo, id: \.sectionIndex) { curSection in
                                if let course = today_courses.HasCourseInSection(sectionId: curSection.sectionIndex) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10) // 圆角矩形
                                            .stroke(Color.white.opacity(0.5), lineWidth: 2) // 白色半透明描边
                                            .frame(height: GetCourseBlockHeight(course))
                                            .background(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(gradient: Gradient(colors: [course.CourseBgColor.opacity(0.7), course.CourseBgColor.opacity(1)]), startPoint: .topTrailing, endPoint: .bottomLeading)))
                                        VStack(spacing: 0) {
                                            // 课程名
                                            Text(course.CourseName.DashIfEmpty()) // 文本内容
                                                .font(.system(size: 13))
                                                .foregroundColor(chooseTextColor(UIColor(course.CourseBgColor))) // 文字颜色
                                                .bold()
                                                .multilineTextAlignment(.center) // 文本居中对齐
                                                .padding(.horizontal, 5)
                                                .truncationMode(.tail)
                                            if !course.ClassroomLocation.isEmpty {
                                                // 上课地点
                                                Text("@\(course.SchoolRegion)\(course.ClassroomLocation)") // 文本内容
                                                    .font(.system(size: 13))
                                                    .foregroundColor(chooseTextColor(UIColor(course.CourseBgColor)))
                                                    .bold()
                                                    .multilineTextAlignment(.center) // 文本居中对齐
                                                    .padding(.horizontal, 5)
                                                    .truncationMode(.tail)
                                            }
                                            if !course.TeacherName.isEmpty {
                                                Text("\(course.TeacherName)") // 文本内容
                                                    .font(.system(size: 13))
                                                    .foregroundColor(chooseTextColor(UIColor(course.CourseBgColor)))
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 5)
                                                    .padding(.top, 15)
                                            }
                                        }
                                        .padding(.vertical, 2)
                                        .frame(maxHeight: GetCourseBlockHeight(course))
                                    }
                                    .onTapGesture {
                                        detailSheetCourse = course
                                        showDetailSheet = true
                                    }
                                } else if today_courses.IsSectionFree(sectionId: curSection.sectionIndex) {
                                    // 如果没课，则绘制空白占位框
                                    Text("占")
                                        .frame(height: CGFloat(UnitBlockHeight))
                                        .opacity(0.001)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        // .background(.yellow)
                    }
                }
            }
                .foregroundColor(.black)
        }
        .sheet(isPresented: $showDetailSheet) {
            ScheduleCourseDetailView(courseObject: detailSheetCourse)
        }
        .onFirstAppear {
            print("OnFirstAppear: Week \(weekIndex)")
            // 载入节数信息
            // sectionInfo = ScheduleManager.shared.GetScheduleSectionInfo()
            // 载入时间信息
            // firstDate = ScheduleManager.shared.GetScheduleDisplayFirstWeek(context: managedObjContext)
//            (currentMonth, dateDayArr, dateDayDateArr) = ScheduleManager.shared.GetWeekDisplayInfo(firstWeek: firstDate, targetWeekIndex: weekIndex)
        }
    }
}


struct ScheduleMainView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @State var selection: Int = 1
    @Environment(\.dismiss) var dismiss
    
    @State var currentDateString = ""
    
    @State var currentViewWeekIndex = 1
    @State var currentWeekDescriptionText = "当前周"
    
    @State var showImportSheet = false
    @State var showExportSheet = false
    
    
    @State var allWeekSchedule: [[DailyScheduleInfo]] = [[DailyScheduleInfo]]()
    
    @State var weekOffset: Int = 0
    
    @State var sectionInfo: [ScheduleSectionInfo] = []
    @State var firstDate: Date = .now
    @State var currentMonthStrArr: [String] = []
    @State var dateDayArr: [[String]] = [[String]]()
    @State var dateDayDateArr: [[Date]] = [[Date]]()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Color.blue.opacity(0.1).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        // 返回上一级
                        VibrateOnce()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(Font.system(size: 25).weight(.semibold))
                    }
                    .foregroundColor(.white)
                    VStack(spacing: 5) {
                        HStack {
                            Text(currentDateString)
                                .bold()
                                .font(.system(size: 25))
                            Spacer()
                        }
                        .onAppear {
                            currentDateString = ScheduleManager.shared.GetCurrentDateString()
                        }
                        HStack {
                            Text("第\(selection-weekOffset)周")
                            Text("\(currentWeekDescriptionText)")
                            Spacer()
                        }
                        .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
//                    .background(.red)
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            // 导出到日程表
                            VibrateOnce()
                            showExportSheet = true
                        }) {
                            Image(systemName: "calendar.badge.plus")
                                .font(Font.system(size: 25).weight(.semibold))
                        }
                        .sheet(isPresented: $showExportSheet) {
                            ExportCalendarView()
                        }
                        Button(action: {
                            // 导入学校的课程表
                            VibrateOnce()
                            showImportSheet = true
                        }) {
                            Image(systemName: "arrow.down.circle")
                                .font(Font.system(size: 25).weight(.semibold))
                        }
                        .sheet(isPresented: $showImportSheet) {
                            ImportScheduleView()
                        }
                    }
                    .foregroundColor(.white)
                }
                .padding() // 顶部元素的内边距
                .background(Color.blue) // 确保顶部栏背景色与整体背景一致
                ZStack {
                    TabView(selection: $selection) {
                        ForEach(allWeekSchedule.indices, id: \.self) { weekId in
                            WeeklyScheduleView(weekIndex: weekId, dateDayArr: $dateDayArr[weekId], dateDayDateArr: $dateDayDateArr[weekId], sectionInfo: $sectionInfo, firstDate: $firstDate, currentMonth: $currentMonthStrArr[weekId], dailyCourses: $allWeekSchedule[weekId])
                                .tag(weekId + 1)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: selection) { newVal in
                        currentWeekDescriptionText = ScheduleManager.shared.GetWeekDesText(context: managedObjContext, selectionWeekIndex: newVal - 1, firstDateProvided: firstDate)
                    }
                    HStack {
                        Rectangle()
                            .foregroundColor(.blue.opacity(0.01))
                            .frame(maxHeight: .infinity)
                            .frame(width: 20)
                        Spacer()
                    }
                }
                
            }
        }
        .onFirstAppear {
            print("on first appear")
            NotificationCenter.default.post(name: refreshScheduleListNotification, object: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: refreshScheduleListNotification)) { param in
            sectionInfo = ScheduleManager.shared.GetScheduleSectionInfo()
            firstDate = ScheduleManager.shared.GetScheduleDisplayFirstWeek(context: managedObjContext)
            
            var (tmp_allWeekSchedule, weekOffset) = ScheduleManager.shared.GenerateAllWeekScheduleInSemester(context: managedObjContext, firstDateProvided: firstDate)
            for i in 0..<tmp_allWeekSchedule.count {
                let (tmp_currentMonth, tmp_dateDayArr, tmp_dateDayDateArr) = ScheduleManager.shared.GetWeekDisplayInfo(firstWeek: firstDate, targetWeekIndex: i)
                currentMonthStrArr.append(tmp_currentMonth)
                dateDayArr.append(tmp_dateDayArr)
                dateDayDateArr.append(tmp_dateDayDateArr)
            }
            allWeekSchedule = tmp_allWeekSchedule
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                selection = ScheduleManager.shared.GetCurrentWeekSelection(context: managedObjContext, firstDateProvided: firstDate)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ScheduleMainView()
}
