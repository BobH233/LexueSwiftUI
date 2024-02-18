//
//  ScoreWidgetView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import WidgetKit
import SwiftUI

struct ScoreWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: ScoreDefaultEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            Score_SmallView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://score_view"))
        case .systemMedium:
            Score_MediumView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://score_view"))
        case .systemLarge:
            Score_LargeView(entry: entry)
                .widgetURL(URL(string: "lexuehelper://score_view"))
        default:
            EmptyView()
        }
    }
}
