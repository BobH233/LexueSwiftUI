//
//  WidgetView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import SwiftUI

struct WidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: DefaultEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            Event_SmallView(entry: entry)
        case .systemMedium:
            Event_SmallView()
        case .systemLarge:
            Event_SmallView()
        default:
            EmptyView()
        }
    }
}
