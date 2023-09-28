//
//  Provider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DefaultEntry {
        print("placeholder")
        return DefaultEntry(date: Date(), str: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (DefaultEntry) -> ()) {
        print("getSnapshot")
        let entry = DefaultEntry(date: .now, str: "lalallala")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DefaultEntry>) -> ()) {
        print("getTimeline")
        let entry = DefaultEntry(date: .now, str: "lalallala2")
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60)))
        completion(timeline)
    }
}
