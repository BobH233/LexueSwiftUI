//
//  ScoreProvider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import Foundation
import WidgetKit
import UserNotifications
import CoreData

struct ScoreProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreDefaultEntry {
        var ret = ScoreDefaultEntry()
        ret.isLogin = true
        ret.isEnableScoreMonitor = true
        return ret
    }

    func getSnapshot(in context: Context, completion: @escaping (ScoreDefaultEntry) -> ()) {
        var entry = ScoreDefaultEntry()
        entry.isLogin = true
        entry.isEnableScoreMonitor = true
        completion(entry)
    }
    
    func CalcEntryInfo(context widget_context: Context, db_context context: NSManagedObjectContext = DataController.shared.container.viewContext) async -> ScoreDefaultEntry {
        var new_entry = ScoreDefaultEntry()
        new_entry.size = widget_context.displaySize
        new_entry.isEnableScoreMonitor = false
        if let monitor = DataProviderManager.shared.FindProvider(providerId: "provider.score_monitor") {
            new_entry.isEnableScoreMonitor = monitor.enabled
        }
        var allScores = DataController.shared.queryAllScoreDiffCache(context: context)
        
        new_entry.isLogin = (GlobalVariables.shared.cur_lexue_context.MoodleSession !=  "")
        new_entry.total_cnt = allScores.count
        new_entry.unread_cnt = 0
        for score in allScores {
            if !score.read {
                new_entry.unread_cnt += 1
            }
        }
        allScores.sort{ (score1, score2) in
            let score1_read = score1.read ? 1 : 0
            let score2_read = score2.read ? 1 : 0
            
            let score1_update = score1.last_update ?? Date.now
            let score2_update = score2.last_update ?? Date.now
            
            let score1_id = Int(score1.scoreId ?? "0") ?? 0
            let score2_id = Int(score2.scoreId ?? "0") ?? 0
            
            if score1_read != score2_read {
                return score1_read < score2_read
            } else if score1_update != score2_update {
                return score1_update > score2_update
            } else {
                return score1_id > score2_id
            }
        }
        
        new_entry.scores = allScores
        return new_entry
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreDefaultEntry>) -> ()) {
        print("getTimeline2")
        let nowTime = Date.now.timeIntervalSince1970
        let lastAppRefresh = SettingStorage.shared.get_widget_shared_AppActiveDate()
        GlobalVariables.shared.cur_lexue_context = SettingStorage.shared.get_widget_shared_LexueContext()
        GlobalVariables.shared.cur_lexue_sessKey = SettingStorage.shared.get_widget_shared_sesskey()
        let isLogin = (GlobalVariables.shared.cur_lexue_context.MoodleSession !=  "")
        if isLogin && nowTime - lastAppRefresh > 60 * 2 {
            // 完成app的事件刷新
            // 只在app在前台不响应超过2分钟才刷新
            SettingStorage.shared.set_widget_shared_AppActiveDate(nowTime)
            Task(timeout: 50) {
                do {
                    print("Refreshing data providers2...")
                    await DataProviderManager.shared.DoRefreshAll(param: ["userId": SettingStorage.shared.cacheUserInfo.userId])
                } catch {
                    print("刷新消息超时!")
                }
                var new_entry = await CalcEntryInfo(context: context)
                let new_timeline = Timeline(entries: [new_entry], policy: .after(.now.advanced(by: 10 * 60)))
                completion(new_timeline)
            }
        } else {
            Task(timeout: 50) {
                let default_entry = await CalcEntryInfo(context: context)
                let default_timeline = Timeline(entries: [default_entry], policy: .after(.now.advanced(by: 10 * 60)))
                completion(default_timeline)
            }
        }
    }
}
