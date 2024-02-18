//
//  WidgetView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import SwiftUI

struct EventWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: EventDefaultEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            Event_SmallView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://event_view"))
        case .systemMedium:
            Event_MediumView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://event_view"))
        case .systemLarge:
            Event_LargeView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://event_view"))
        default:
            EmptyView()
        }
    }
}
