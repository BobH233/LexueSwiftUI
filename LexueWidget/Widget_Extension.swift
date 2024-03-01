//
//  Widget_Extension.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import SwiftUI



struct LexueEventWidget: Widget {
    let kind: String = "LexueWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EventProvider()) { entry in
            if #available(iOS 17.0, *) {
                EventWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                EventWidgetView(entry: entry)
                    .padding()
                    .background()
            }
            
        }
        .configurationDisplayName("乐学助手-事件列表")
        .supportedFamilies([.systemMedium, .systemLarge, .systemSmall])
        .description("按时间顺序显示待完成的事项")
    }
}

struct ScoreMonitorWidget: Widget {
    let kind: String = "ScoreMonitorWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScoreProvider()) { entry in
            if #available(iOS 17.0, *) {
                ScoreWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ScoreWidgetView(entry: entry)
                    .padding()
                    .background()
            }
            
        }
        .configurationDisplayName("乐学助手-成绩监控")
        .supportedFamilies([.systemMedium, .systemLarge, .systemSmall])
        .description("显示实时的成绩更新情况")
    }
}


struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleProvider()) { entry in
            if #available(iOS 17.0, *) {
                ScheduleWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ScheduleWidgetView(entry: entry)
                    .padding()
                    .background()
            }
            
        }
        .configurationDisplayName("乐学助手-课程表")
        .supportedFamilies([.systemMedium, .systemLarge])
        .description("显示每日课程表")
    }
}
