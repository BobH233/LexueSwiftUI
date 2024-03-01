//
//  WidgetView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import SwiftUI

struct ScheduleWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: ScheduleDefaultEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            Schedule_MediumView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://schedule_view"))
        case .systemLarge:
            Schedule_LargeView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://schedule_view"))
        default:
            EmptyView()
        }
    }
}
