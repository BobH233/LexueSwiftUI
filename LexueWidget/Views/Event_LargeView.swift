//
//  Event_LargeView.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2023/10/4.
//

import WidgetKit
import SwiftUI

struct Event_LargeView: View {
    var entry: DefaultEntry = DefaultEntry()
    @State var limited_event: [EventStored] = []
    let firstLineSize: CGFloat = 14
    let secondLineSize: CGFloat = 16
    var body: some View {
        Event_MediumView(entry: entry, firstLineSize: 16, secondLineSize: 18, limitCount: 6)
    }
}

#Preview {
    Event_LargeView()
}

struct Event_LargeView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Event_LargeView()
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        } else {
            Event_LargeView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
        
    }
}
