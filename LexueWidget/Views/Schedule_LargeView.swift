//
//  Event_LargeView.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2023/10/4.
//

import WidgetKit
import SwiftUI

struct Schedule_LargeView: View {
    var entry: ScheduleDefaultEntry = ScheduleDefaultEntry()
    @State var limited_event: [EventStored] = []
    let firstLineSize: CGFloat = 14
    let secondLineSize: CGFloat = 16
    var body: some View {
        Schedule_MediumView(entry: entry, firstLineSize: 16, secondLineSize: 18, limitCount: 6)
    }
}

#Preview {
    Schedule_LargeView()
}

struct Schedule_LargeView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Event_LargeView()
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        } else {
            Event_LargeView()
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
        
    }
}
