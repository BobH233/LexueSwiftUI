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
        case .systemMedium:
            Score_MediumView(entry: entry)
        case .systemLarge:
            Score_LargeView(entry: entry)
        default:
            EmptyView()
        }
    }
}
