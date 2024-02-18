//
//  ScoreDefaultEntry.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import WidgetKit

struct ScoreDefaultEntry: TimelineEntry {
    var date: Date = Date()
    var size: CGSize = CGSize()
    var isEnableScoreMonitor: Bool = true
    var isLogin: Bool = false
    var unread_cnt: Int = 0
    var total_cnt: Int = 0
    var scores: [ScoreDiffCache] = []
}

extension ScoreDefaultEntry {
    func GetDayText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M.d"
        return dateFormatter.string(from: date)
    }
    func GetWeekdayText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}
