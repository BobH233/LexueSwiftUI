//
//  Event_View.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2023/10/4.
//

import WidgetKit
import SwiftUI

struct ScheduleItemView: View {
    @State var color: Color
    @State var courseName: String
    @State var description: String
    
    @State var starttime: String
    @State var endtime: String
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 4)
                .foregroundColor(color)
                .cornerRadius(2)
            VStack {
                HStack {
                    Text(courseName)
                        .bold()
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.top, 1)
                HStack {
                    Text(description)
                        .font(.system(size: 15))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.bottom, 1)
            }
            Spacer()
            VStack {
                Text(starttime)
                    .font(.system(size: 14))
                Text(endtime)
                    .font(.system(size: 14))
            }
            .padding(.trailing, 5)
        }
        .frame(maxHeight: 60)
        .background(color.opacity(0.1))
    }
}

struct Schedule_MediumView: View {
    var entry: ScheduleDefaultEntry = ScheduleDefaultEntry()
    
    @State var limited_schedule: [JXZXehall.ScheduleCourseInfo] = []
    
    
    var firstLineSize: CGFloat = 14
    var secondLineSize: CGFloat = 16
    var limitCount: Int = 2
    @State var showTomorrowTips = false
    @State var showTomorrowSchedule = false
    @State var todayContentCount = 0
    
    
    var body: some View {
        VStack(spacing: 2) {
            if entry.isLogin {
                HStack {
                    Text("乐学助手")
                        .font(.system(size: firstLineSize))
                    Text("|")
                        .font(.system(size: firstLineSize))
                    Text(entry.GetDayText())
                        .font(.system(size: firstLineSize))
                    Text("|")
                        .font(.system(size: firstLineSize))
                    Text(entry.GetWeekdayText())
                        .foregroundColor(.red)
                        .font(.system(size: firstLineSize))
                    Spacer()
                }
                .padding(.bottom, 5)
                if showTomorrowSchedule {
                    if entry.tomorrow_courses.count > 0 {
                        HStack {
                            Text("明天还有\(entry.tomorrow_courses.count)门课")
                                .font(.system(size: firstLineSize))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("明天没有课了哦~")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                }
                ForEach(limited_schedule) { course in
                    ScheduleItemView(color: course.CourseBgColor, courseName: course.CourseName, description: "\(course.GetFullLocationText()) \(course.TeacherName)", starttime: ScheduleManager.shared.GetCourseSectionTimeText(sectionId: course.StartSectionId, is_start_text: true), endtime: ScheduleManager.shared.GetCourseSectionTimeText(sectionId: course.EndSectionId, is_start_text: false))
                }
                if limited_schedule.count < todayContentCount {
                    HStack {
                        Text("还有\(todayContentCount - limited_schedule.count)门课未显示")
                            .font(.system(size: firstLineSize))
                        Spacer()
                    }
                } else if showTomorrowTips {
                    if entry.tomorrow_courses.count > 0 {
                        HStack {
                            Text("明天还有\(entry.tomorrow_courses.count)门课")
                                .font(.system(size: firstLineSize))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("明天没有课了哦~")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                }
                Spacer()
            } else {
                Spacer()
                Image(systemName: "person")
                HStack {
                    Spacer()
                    Text("请先登录乐学助手")
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            // 计算要显示的内容
            var today_content: [JXZXehall.ScheduleCourseInfo] = []
            for today_course in entry.today_courses {
                if ScheduleManager.shared.IsCourseEnded(course: today_course) {
                    continue
                }
                today_content.append(today_course)
            }
            todayContentCount = today_content.count
            if today_content.count > 0 {
                
                // 如果今天还有课，则只显示今天课程，不显示明天的课程，并且要显示明天还有几门课
                for i in 0 ..< min(today_content.count, limitCount) {
                    limited_schedule.append(today_content[i])
                }
                showTomorrowTips = true
                showTomorrowSchedule = false
            } else {
                for i in 0 ..< min(entry.tomorrow_courses.count, limitCount) {
                    limited_schedule.append(entry.tomorrow_courses[i])
                }
                showTomorrowTips = false
                showTomorrowSchedule = true
            }
        }
    }
}
