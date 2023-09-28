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
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Test widget")
        .supportedFamilies([.systemMedium, .systemLarge])
        .description("This is test description")
    }
}
