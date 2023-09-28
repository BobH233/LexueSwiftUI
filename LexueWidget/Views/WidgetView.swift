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
        VStack {
            Text("\(entry.date)")
            Text("\(entry.str)")
        }
    }
}
