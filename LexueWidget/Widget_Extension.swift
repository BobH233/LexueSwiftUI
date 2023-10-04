//
//  Widget_Extension.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import SwiftUI



struct LexueWidget: Widget {
    let kind: String = "LexueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetView(entry: entry)
                    .padding()
                    .background()
            }
            
        }
        .configurationDisplayName("乐学助手-事件列表")
        .supportedFamilies([.systemMedium, .systemLarge, .systemSmall])
        .description("按时间顺序显示待完成的事项")
    }
}
