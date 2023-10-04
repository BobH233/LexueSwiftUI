//
//  Event_View.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2023/10/4.
//

import WidgetKit
import SwiftUI

struct EventItemView: View {
    @State var color: Color
    @State var eventName: String
    @State var starttime: Date
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 4)
                .foregroundColor(color)
                .cornerRadius(2)
            VStack {
                HStack {
                    Text(eventName)
                        .font(.system(size: 17))
                    Spacer()
                }
                .padding(.top, 1)
                HStack {
                    Text(GetDateDescriptionText(sendDate: starttime))
                        .font(.system(size: 15))
                    Spacer()
                }
                .padding(.bottom, 1)
            }
            Spacer()
        }
        .background(color.opacity(0.1))
    }
}

struct Event_MediumView: View {
    var entry: DefaultEntry = DefaultEntry()
    @State var limited_event: [EventStored] = []
    var firstLineSize: CGFloat = 14
    var secondLineSize: CGFloat = 16
    var limitCount: Int = 2
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text("乐学助手")
                    .font(.system(size: firstLineSize))
                Text("|")
                    .font(.system(size: firstLineSize))
                Text(entry.GetDayText())
                    .font(.system(size: firstLineSize))
                Text("|")
                    .font(.system(size: firstLineSize))
                Text(entry.GetWeekdayText())
                    .foregroundColor(.red)
                    .font(.system(size: firstLineSize))
                Spacer()
            }
            HStack(alignment: .bottom) {
                Text("今日")
                    .font(.system(size: secondLineSize))
                Text("\(entry.day_event_count)")
                    .bold()
                    .foregroundColor(.blue)
                    .font(.system(size: secondLineSize))
                Text("个")
                    .font(.system(size: secondLineSize))
                Text("|")
                    .font(.system(size: secondLineSize))
                Text("本周")
                    .font(.system(size: secondLineSize))
                Text("\(entry.week_event_count)")
                    .bold()
                    .foregroundColor(.orange)
                    .font(.system(size: secondLineSize))
                Text("个")
                    .font(.system(size: secondLineSize))
                Spacer()
            }
            .padding(.bottom, 3)
            ForEach(limited_event) { event in
                EventItemView(color: Color(hex: event.color ?? "") ?? .blue, eventName: event.name ?? "", starttime: event.timestart ?? Date())
            }
            Spacer()
        }
        .onAppear {
            // 最多显示 2 个
            for i in 0 ..< min(entry.events.count, limitCount) {
                limited_event.append(entry.events[i])
            }
        }
    }
}

struct Event_MediumView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Event_MediumView()
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        } else {
            Event_MediumView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
        
    }
}
