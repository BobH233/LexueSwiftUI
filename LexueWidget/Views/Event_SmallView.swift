//
//  Event_SmallView.swift
//  LexueWidgetExtension
//
//  Created by bobh on 2023/10/4.
//

import WidgetKit
import SwiftUI

struct Event_SmallView: View {
    var entry: DefaultEntry = DefaultEntry()
    var body: some View {
        VStack(spacing: 10) {
            if entry.isLogin {
                HStack {
                    Text(entry.GetDayText())
                    Text("|")
                    Text(entry.GetWeekdayText())
                        .foregroundColor(.red)
                    Spacer()
                }
                HStack {
                    Text("乐学助手")
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Rectangle()
                        .frame(width: 4)
                        .foregroundColor(.blue)
                        .cornerRadius(2)
                    Text("今日")
                    Text("\(entry.day_event_count)")
                        .font(.system(size: 25))
                        .bold()
                        .foregroundColor(.blue)
                    Text("个")
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Rectangle()
                        .frame(width: 4)
                        .foregroundColor(.orange)
                        .cornerRadius(2)
                    Text("本周")
                    Text("\(entry.week_event_count)")
                        .font(.system(size: 25))
                        .bold()
                        .foregroundColor(.orange)
                    Text("个")
                    Spacer()
                }
                .padding(.bottom, 5)
            } else {
                Spacer()
                Image(systemName: "person")
                HStack {
                    Spacer()
                    Text("请先登录乐学助手")
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct Event_SmallView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Event_SmallView(entry: DefaultEntry(isLogin: true))
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        } else {
            Event_SmallView(entry: DefaultEntry(isLogin: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
        
    }
}
