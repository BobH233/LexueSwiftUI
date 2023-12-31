//
//  DDLListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import SwiftSoup
import SwiftUI
import AudioToolbox

private struct TopCardView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.managedObjectContext) var managedObjContext
    @State var greetingWord = "早上好，"
    @State var todayEventCount = 0
    @State var weekEventCount = 0
    @State var dateString = ""
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
                        Text(dateString)
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
                        Text("今日还有")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Text("\(todayEventCount)")
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
                        Text("本周还有")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Text("\(weekEventCount)")
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
            EventManager.shared.LoadEventList(context: managedObjContext)
            todayEventCount = EventManager.shared.GetTodayEventCount(today: Date())
            weekEventCount = EventManager.shared.GetWeekEventCount(todayInWeek: Date())
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M月d日 EEEE"
            dateString = dateFormatter.string(from: .now)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                greetingWord = getGreetingWord()
                EventManager.shared.LoadEventList(context: managedObjContext)
                todayEventCount = EventManager.shared.GetTodayEventCount(today: Date())
                weekEventCount = EventManager.shared.GetWeekEventCount(todayInWeek: Date())
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M月d日 EEEE"
                dateString = dateFormatter.string(from: .now)
            @unknown default:
                break
            }
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

struct EventListItemView: View {
    @Binding var title: String?
    @Binding var description: String?
    @Binding var isPeriodEvent: Bool
    @Binding var starttime: Date?
    @Binding var endtime: Date?
    @Binding var courseName: String?
    @Binding var backgroundCol: String?
    
    
    func chooseTextColor(for backgroundColor: UIColor) -> Color {
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
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                HStack {
                    Text(title ?? "无标题事件")
                        .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
                        .bold()
                        .font(.system(size: 30))
                        .lineLimit(1)
                        .padding(.trailing, 20)
                    Spacer()
                }
                HStack {
                    Text(GetHtmlText(description ?? ""))
                        .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
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
                                .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
                            Text(courseName!)
                                .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
                                .bold()
                                .font(.system(size: 15))
                            Spacer()
                        }
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
                        if !isPeriodEvent {
                            Text(GetDateDescriptionText(sendDate: starttime ?? Date()))
                                .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
                                .bold()
                                .font(.system(size: 15))
                        } else {
                            Text(GetDatePeriodDescriptionText(starttime: starttime ?? Date(), endtime: endtime ?? Date()))
                                .foregroundColor(chooseTextColor(for: UIColor(backgroundCol == nil ? .green : (Color(hex: backgroundCol!) ?? .green))))
                                .bold()
                                .font(.system(size: 15))
                        }
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
    @Binding var tabSelection: Int
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var eventManager = EventManager.shared
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var showTodayOnly: Bool = false
    @State var showSettingView: Bool = false
    @State var showNewEventView: Bool = false
    @State var curSelectEventUUID: UUID = UUID()
    @State var showEditEventView: Bool = false
    @State var showDeletedEventView: Bool = false
    
    @State var refreshingEvents: Bool = false
    //  @Binding var tabSelection: Int
    var body: some View {
        if globalVar.isLogin {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Spacer()
                        VStack {
                            TopCardView()
                                .padding(.horizontal, 15)
                            HStack(spacing: 10) {
                                FunctionalButtonView(backgroundCol: .blue, iconSystemName: "plus.circle.fill", title: "手动添加日程")
                                    .onTapGesture {
                                        showNewEventView.toggle()
                                    }
                                FunctionalButtonView(backgroundCol: .gray, iconSystemName: "gear", title: "设置规则")
                                    .onTapGesture {
                                        showSettingView.toggle()
                                    }
                            }
                            .padding(.horizontal, 15)
                            HStack {
                                if showTodayOnly {
                                    FunctionalButtonView(backgroundCol: .blue, iconSystemName: "eye.slash.fill", title: "当前：仅显示今天事件")
                                        .onTapGesture {
                                            withAnimation {
                                                showTodayOnly.toggle()
                                            }
                                            VibrateOnce()
                                        }
                                } else {
                                    FunctionalButtonView(backgroundCol: .blue, iconSystemName: "eye.slash", title: "当前：显示一周内事件")
                                        .onTapGesture {
                                            withAnimation {
                                                showTodayOnly.toggle()
                                            }
                                            VibrateOnce()
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
                                    if !showTodayOnly || EventManager.IsTodayEvent(event: event.wrappedValue, today: .now) {
                                        EventListItemView(title: event.name, description: event.event_description, isPeriodEvent: event.is_period_event, starttime: event.timestart,endtime: event.timeend, courseName: event.course_name, backgroundCol: event.color)
                                            .onTapGesture {
                                                curSelectEventUUID = event.id!
                                                showEditEventView = true
                                            }
                                    }
                                }
                            }
                            .onAppear {
                                EventManager.shared.LoadEventList(context: managedObjContext)
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 15)
                            
                            if !showTodayOnly {
                                // 已经到期或者完成的ddl
                                LazyVStack {
                                    HStack {
                                        Text("已过期/已完成:")
                                            .font(.system(size: 30))
                                            .bold()
                                        Spacer()
                                    }
                                    ForEach($eventManager.expiredEventDisplayList, id: \.id) { event in
                                        EventListItemView(title: event.name, description: event.event_description, isPeriodEvent: event.is_period_event, starttime: event.timestart,endtime: event.timeend, courseName: event.course_name, backgroundCol: event.color)
                                            .onTapGesture {
                                                curSelectEventUUID = event.id!
                                                showEditEventView = true
                                            }
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 15)
                            }
                            NavigationLink("", isActive: $showSettingView, destination: {
                                EventPreferenceSettingView()
                            })
                            .isDetailLink(false)
                            .hidden()
                            NavigationLink("", isActive: $showNewEventView, destination: {
                                AddCustomEventView()
                            })
                            .isDetailLink(false)
                            .hidden()
                            NavigationLink("", isActive: $showEditEventView, destination: {
                                ViewEventView(event_uuid: curSelectEventUUID)
                            })
                            .isDetailLink(false)
                            .hidden()
                            NavigationLink("", isActive: $showDeletedEventView, destination: {
                                DeletedEventView()
                            })
                            .isDetailLink(false)
                            .hidden()
                        }
                        .frame(maxWidth: 800)
                        Spacer()
                    }
                }
                .onChange(of: showTodayOnly) { newVal in
                    SettingStorage.shared.event_showTodayOnly = showTodayOnly
                }
                .onAppear {
                    showTodayOnly = SettingStorage.shared.event_showTodayOnly
                }
                .onReceive(NotificationCenter.default.publisher(for: .onDatabaseUpdate)) { _ in
                    print("数据库更新，重新刷新事件列表!")
                    withAnimation {
                        EventManager.shared.LoadEventList()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Section {
                                Button(role: .destructive, action: {
                                    EventManager.shared.DeleteAllExpiredEvent(context: managedObjContext)
                                    EventManager.shared.LoadEventList()
                                }) {
                                    Label("删除所有已到期事件", systemImage: "trash.fill")
                                }
                                Button(action: {
                                    showDeletedEventView.toggle()
                                }) {
                                    Label("查看已删除的到期事件", systemImage: "list.bullet")
                                }
                            }
                        }
                    label: {
                        Label("Add", systemImage: "square.and.pencil")
                    }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if refreshingEvents {
                            ProgressView()
                        } else {
                            Button(action: {
                                refreshingEvents = true
                                Task {
                                    try? await CoreLogicManager.shared.UpdateEventList(manually: true)
                                    DispatchQueue.main.async {
                                        refreshingEvents = false
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                }
                .navigationViewStyle(.stack)
                .navigationTitle("最近事件")
                .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            UnloginView(tabSelection: $tabSelection)
        }
    }
}

