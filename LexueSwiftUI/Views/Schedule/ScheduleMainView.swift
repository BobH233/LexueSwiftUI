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
    @State var dateDayArr: [String] = [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7"
    ]
    @State var dateDayDateArr: [Date] = [
        .now,
        .now,
        .now,
        .now,
        .now,
        .now,
        .now
    ]
    
    @State var sectionInfo: [ScheduleSectionInfo] = [
    ]
    @State var firstDate: Date = .now
    @State var currentMonth = "2月"
    
    // 每天的课程
    @State var dailyCourses: [DailyScheduleInfo] = [
        .init(day_index: 1, courses_today: [
            .init(CourseName: "会员制餐厅导论", TeacherName: "醇平", ClassroomLocation:"会员制餐厅", StartSectionId: 1, EndSectionId: 2, CourseBgColor: .brown),
            .init(CourseName: "如何赚钱", TeacherName: "申家芮", ClassroomLocation:"北京良乡看守所", StartSectionId: 5, EndSectionId: 8, CourseBgColor: .yellow),
        ]),
        .init(day_index: 2, courses_today: []),
        .init(day_index: 3, courses_today: [
            .init(CourseName: "数据结构与编曲", TeacherName: "泽野螳螂", ClassroomLocation:"Bilibili", StartSectionId: 3, EndSectionId: 5),
            .init(CourseName: "哲学与人生", TeacherName: "VanSama", ClassroomLocation:"博雅更衣室", StartSectionId: 6, EndSectionId: 7, CourseBgColor: .pink),
        ]),
        .init(day_index: 4, courses_today: []),
        .init(day_index: 5, courses_today: []),
        .init(day_index: 6, courses_today: []),
        .init(day_index: 7, courses_today: []),
    ]
    
    func GetCourseBlockHeight(_ course: JXZXehall.ScheduleCourseInfo) -> CGFloat {
        let height: Float = (UnitBlockHeight + 3.0) * Float(course.GetSectionLength()) - 3.0
        return CGFloat(height)
    }
    
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
                            // .background(.red)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    // .background(.green)
                    ForEach(dailyCourses, id: \.day_index) { today_courses in
                        VStack(spacing: 3) {
                            ForEach(sectionInfo, id: \.sectionIndex) { curSection in
                                if let course = today_courses.HasCourseInSection(sectionId: curSection.sectionIndex) {
                                    // 如果这里有课, 那么就绘制课程框
                                    //                                    Text(course.CourseName)
                                    //                                        .frame(height: GetCourseBlockHeight(course))
                                    //                                        .background(.blue)
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
                                                Text("@\(course.ClassroomLocation)") // 文本内容
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
        .onAppear {
            // 载入节数信息
            sectionInfo = ScheduleManager.shared.GetScheduleSectionInfo()
            // 载入时间信息
            firstDate = ScheduleManager.shared.GetScheduleDisplayFirstWeek(context: managedObjContext)
            (currentMonth, dateDayArr, dateDayDateArr) = ScheduleManager.shared.GetWeekDisplayInfo(firstWeek: firstDate, targetWeekIndex: weekIndex)
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
                            Text("第\(selection)周")
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
                        }) {
                            Image(systemName: "calendar.badge.plus")
                                .font(Font.system(size: 25).weight(.semibold))
                        }
                        Button(action: {
                            // 导入学校的课程表
                        }) {
                            Image(systemName: "arrow.down.circle")
                                .font(Font.system(size: 25).weight(.semibold))
                        }
                    }
                    .foregroundColor(.white)
                }
                .padding() // 顶部元素的内边距
                .background(Color.blue) // 确保顶部栏背景色与整体背景一致
                ZStack {
                    TabView(selection: $selection) {
                        WeeklyScheduleView(weekIndex: 0)
                        // .background(.yellow)
                            .tag(1)
                        WeeklyScheduleView(weekIndex: 1)
                        // .background(.yellow)
                            .tag(2)
                        WeeklyScheduleView(weekIndex: 2)
                        // .background(.yellow)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .ignoresSafeArea(.all, edges: .bottom)
                    .onChange(of: selection) { newVal in
                        currentWeekDescriptionText = ScheduleManager.shared.GetWeekDesText(context: managedObjContext, selectionWeekIndex: newVal - 1)
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
        .navigationBarHidden(true)
    }
}

#Preview {
    ScheduleMainView()
}
