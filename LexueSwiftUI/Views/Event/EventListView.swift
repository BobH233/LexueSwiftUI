//
//  DDLListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import SwiftSoup

private struct TopCardView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @State var greetingWord = "早上好，"
    func getGreetingWord() -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        switch hour {
        case 6..<11:
            return "早上好"
        case 11..<14:
            return "中午好"
        case 14..<18:
            return "下午好"
        case 18..<23:
            return "晚上好"
        default:
            return "早点睡"
        }
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.orange)
                .frame(height: 300)
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                VStack(spacing: 5) {
                    HStack {
                        Text(greetingWord + "，")
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.white)
                        Text(globalVar.cur_user_info.fullName)
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack {
                        Text("10月1日 星期日")
                            .font(.system(size: 25))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.leading, 20)
                .padding(.top, 20)
                Spacer()
                VStack {
                    HStack(alignment: .bottom) {
                        Text("今日有")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Text("5")
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.yellow)
                            .shadow(color: .gray, radius: 10)
                        Text("个ddl")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack(alignment: .bottom) {
                        Text("本周有")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Text("5")
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.yellow)
                            .shadow(color: .gray, radius: 10)
                        Text("个ddl")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            greetingWord = getGreetingWord()
        }
    }
}

private struct FunctionalButtonView: View {
    var backgroundCol: Color = .blue
    @State var iconSystemName: String = "plus.circle.fill"
    @State var title: String = "标题"
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundCol)
                .frame(height: 100)
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                HStack {
                    Image(systemName: iconSystemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.leading, 10)
                Spacer()
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                }
                .padding(.bottom, 10)
                .padding(.leading, 10)
            }
        }
        
    }
}

private struct EventListItemView: View {
    @Binding var title: String?
    @Binding var description: String?
    @Binding var endtime: Date?
    // var endtime: String = "DDL结束时间"
    @Binding var courseName: String?
    var backgroundCol: Color = .green
    func GetHtmlText(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            let text = try document.text()
            return text
        } catch {
            print("解析HTML出错：\(error)")
            return ""
        }
    }
    func GetDateDescriptionText(sendDate: Date) -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh-CN")
        if sendDate.isInSameDay(as: today) {
            dateFormatter.dateFormat = "今天 HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if Calendar.current.isDateInYesterday(sendDate) {
            dateFormatter.dateFormat = "昨天 HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if Calendar.current.isDateInTomorrow(sendDate) {
            dateFormatter.dateFormat = "明天 HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if sendDate.isInSameWeek(as: today) {
            dateFormatter.dateFormat = "EEEE HH:mm"
            return dateFormatter.string(from: sendDate)
        } else if sendDate.isInSameYear(as: today) {
            dateFormatter.dateFormat = "MM-dd HH:mm"
            return dateFormatter.string(from: sendDate)
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter.string(from: sendDate)
        }
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundCol)
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                HStack {
                    Text(title ?? "无标题事件")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .bold()
                        .lineLimit(1)
                        .padding(.trailing, 20)
                    Spacer()
                }
                HStack {
                    Text(GetHtmlText(description ?? ""))
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .bold()
                        .lineLimit(1)
                        .padding(.trailing, 20)
                    Spacer()
                }
                VStack(spacing: 3) {
                    if courseName != nil{
                        HStack(spacing: 6) {
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.white)
                            Text(courseName!)
                                .foregroundColor(.white)
                                .bold()
                                .font(.system(size: 15))
                            Spacer()
                        }
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                        Text(GetDateDescriptionText(sendDate: endtime ?? Date()))
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 15))
                        Spacer()
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
            .padding(.leading, 10)
        }
    }
}

struct EventListView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var eventManager = EventManager.shared
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var showTodayOnly: Bool = false
    //  @Binding var tabSelection: Int
    var body: some View {
        NavigationView {
            ScrollView {
                TopCardView()
                    .padding(.horizontal, 15)
                HStack(spacing: 10) {
                    FunctionalButtonView(backgroundCol: .blue, iconSystemName: "plus.circle.fill", title: "手动添加日程")
                    FunctionalButtonView(backgroundCol: .gray, iconSystemName: "gear", title: "设置规则")
                }
                .padding(.horizontal, 15)
                HStack {
                    if showTodayOnly {
                        FunctionalButtonView(backgroundCol: .blue, iconSystemName: "eye.slash.fill", title: "当前：仅显示今天事件")
                            .onTapGesture {
                                print("toggle")
                                withAnimation {
                                    showTodayOnly.toggle()
                                }
                            }
                    } else {
                        FunctionalButtonView(backgroundCol: .blue, iconSystemName: "eye.slash", title: "当前：显示一周内事件")
                            .onTapGesture {
                                print("toggle")
                                withAnimation {
                                    showTodayOnly.toggle()
                                }
                            }
                    }
                    
                }
                .padding(.horizontal, 15)
                // 未完成的ddl
                VStack {
                    HStack {
                        Text("未完成:")
                            .font(.system(size: 30))
                            .bold()
                        Spacer()
                    }
                    ForEach($eventManager.EventDisplayList, id: \.id) { event in
                        EventListItemView(title: event.name, description: event.event_description, endtime: event.timestart, courseName: event.course_name)
                            .onTapGesture {
                                withAnimation {
                                    EventManager.shared.FinishEvent(id: event.id!, isFinish: true, context: managedObjContext)
                                }
                            }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 15)
                
                if !showTodayOnly {
                    // 已经到期或者完成的ddl
                    VStack {
                        HStack {
                            Text("已过期/已完成:")
                                .font(.system(size: 30))
                                .bold()
                            Spacer()
                        }
                        ForEach($eventManager.expiredEventDisplayList, id: \.id) { event in
                            EventListItemView(title: event.name, description: event.event_description, endtime: event.timestart, courseName: event.course_name)
                                .onTapGesture {
                                    withAnimation {
                                        EventManager.shared.FinishEvent(id: event.id!, isFinish: false, context: managedObjContext)
                                    }
                                }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 15)
                }
            }
            .navigationTitle("最近事件")
                
        }
        .onFirstAppear {
            eventManager.LoadEventList()
        }
        
    }
}

#Preview {
    EventListView()
}
