//
//  WelcomeUseWidget.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/7.
//

import SwiftUI

struct EventWidgetPreview: View {
    var body: some View {
        ZStack {
            Image("event_widget_large_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .offset(CGSize(width: 20.0, height: 10.0))
            Image("event_widget_medium_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .offset(CGSize(width: -20.0, height: 80.0))
            Image("event_widget_small_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 120)
                .shadow(radius: 10)
                .offset(CGSize(width: 100.0, height: 130.0))
                
        }
    }
}

struct ScoreWidgetPreview: View {
    var body: some View {
        ZStack {
            Image("score_widget_large_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .offset(CGSize(width: 20.0, height: 10.0))
            Image("score_widget_medium_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .offset(CGSize(width: -20.0, height: 80.0))
            Image("score_widget_small_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 120)
                .shadow(radius: 10)
                .offset(CGSize(width: 100.0, height: 130.0))
                
        }
    }
}

struct ScheduleWidgetPreview: View {
    var body: some View {
        ZStack {
            Image("schedule_widget_large_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .offset(CGSize(width: 20.0, height: 10.0))
            Image("schedule_widget_medium_preview")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .offset(CGSize(width: -20.0, height: 80.0))
        }
    }
}

struct WelcomeUseWidget: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var sysColorScheme
    
    func GetDescriptiveText(selectionTag: Int) -> String {
        if selectionTag == 1 {
            return "随时查看事件"
        } else if selectionTag == 2 {
            return "即刻监控你的成绩"
        } else if selectionTag == 3 {
            return "快速查看每天课程"
        }
        return ""
    }
    @State var selection: Int = 1
    @State var selectionAnimated: Int = 1
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text(GetDescriptiveText(selectionTag: selectionAnimated))
                            .font(.largeTitle)
                        Text("推荐使用乐学助手小组件")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                TabView(selection: $selection) {
                    EventWidgetPreview()
                        .tag(1)
                    ScoreWidgetPreview()
                        .tag(2)
                    ScheduleWidgetPreview()
                        .tag(3)
                }
                .onAppear {
                    if sysColorScheme == .light {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .black
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
                    } else {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .white
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.2)
                    }
                }
                // .background(.red)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // 设置样式为页面式，隐藏页码指示器
                Spacer()
                if selectionAnimated < 3 {
                    Button {
                        withAnimation {
                            selection += 1
                        }
                    } label: {
                        Text("下一个")
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                    .padding(.bottom, 20)
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 30)
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("我知道了")
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                    .padding(.bottom, 20)
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 30)
                }
            }
            .frame(maxWidth: 400)
            Spacer()
        }
        .onChange(of: selection) { newVal in
            withAnimation {
                selectionAnimated = newVal
            }
        }
    }
}

#Preview {
    WelcomeUseWidget()
}
