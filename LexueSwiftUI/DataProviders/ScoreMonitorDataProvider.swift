//
//  ScoreMonitorDataProvider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import Foundation
/**
        定时查询成绩，对比差异，及时通知同学成绩更新
 */
class ScoreMonitorDataProvider: DataProvider {
    var providerIdForEach: String {
        return "provider.score_monitor"
    }
    
    var enabled: Bool = true
    
    var allowMessage: Bool = true
    
    var allowNotification: Bool = true
    
    var msgRequestList: [PushMessageRequest] = []
    
    var customOptions: [ProviderCustomOption] = []
    
    func get_default_enabled() -> Bool {
        return true
    }
    
    func get_default_allowMessage() -> Bool {
        return true
    }
    
    func get_default_allowNotification() -> Bool {
        return true
    }
    
    func get_custom_options() -> [ProviderCustomOption] {
        return []
    }
    
    func get_priority() -> TaskPriority {
        return .medium
    }
    
    func info() -> DataProviderInfo {
        return DataProviderInfo(providerId: "provider.score_monitor", providerName: "成绩定时刷新服务", description: "定时拉取最新成绩并检查是否有新增科目，如果有则通知，提供小组件数据", author: "BobH")
    }
    
    func handleApns(data: Any) {
        
    }
    
    func LoadScoresInfo(tryCache: Bool = true) async -> [Webvpn.ScoreInfo]  {
        if tryCache && SettingStorage.shared.cache_webvpn_context != "" && SettingStorage.shared.cache_webvpn_context_for_user == SettingStorage.shared.savedUsername {
            print("Hit Cache, try cache loading score...")
            var context = Webvpn.WebvpnContext(wengine_vpn_ticketwebvpn_bit_edu_cn: SettingStorage.shared.cache_webvpn_context)
            var score_res = await Webvpn.shared.QueryScoreInfo(webvpn_context: context, auto_diff_score: false)
            switch score_res {
            case .success(let ret_scoreInfo):
                return ret_scoreInfo
            case .failure(_):
                return await LoadScoresInfo(tryCache: false)
            }
        } else {
            let login_res = await Webvpn.shared.GetWebvpnContext(username: SettingStorage.shared.savedUsername, password: SettingStorage.shared.savedPassword)
            switch login_res {
            case .success(let context):
                DispatchQueue.main.async {
                    SettingStorage.shared.cache_webvpn_context = context.wengine_vpn_ticketwebvpn_bit_edu_cn
                    SettingStorage.shared.cache_webvpn_context_for_user = SettingStorage.shared.savedUsername
                }
                let score_res = await Webvpn.shared.QueryScoreInfo(webvpn_context: context, auto_diff_score: false)
                switch score_res {
                case .success(let ret_scoreInfo):
                    return ret_scoreInfo
                case .failure(_):
                    return []
                }
            case .failure(_):
                return []
            }
        }
    }
    
    func handleNewScoreInfo(score: Webvpn.ScoreInfo) async {
        await DataController.shared.container.performBackgroundTask { (bgContext) in
            guard let scoreCache = DataController.shared.QueryScoreDiffCache(context: bgContext, scoreHash: score.hash) else {
                return
            }
            var msg = MessageBodyItem(type: .markdown)
            msg.text_data = "## 成绩信息更新提醒：\n\n**课程名称:** \(score.courseName)\n\n**检测更新时间:** \(GetFullDisplayTime(scoreCache.last_update ?? Date.now))\n\n**我的成绩:** \(score.my_score)\n\n**平均分:** \(score.avg_score)\n\n**我的专业排名:** \(score.my_grade_in_major)\n\n**我的全部排名:** \(score.my_grade_in_all)\n\n\n详细分析，请进入\"成绩查询\"功能查看。"
            self.msgRequestList.append(PushMessageRequest(senderUid: "score_monitor", contactOriginNameIfMissing: "成绩监控", contactTypeIfMissing: .msg_provider, msgBody: msg, date: Date()))
        }
    }
    
    func refresh(param: [String : Any], manually: Bool) async {
        // 处理成绩消息
        if !enabled {
            return
        }
        print("刷新成绩信息！")
        // 拉取成绩，获得成绩变动信息
        let curScoreInfo = await LoadScoresInfo()
        let newScoreInfo = await Webvpn.shared.DiffScoreInfoAndUpdate(curScoreInfo: curScoreInfo)
        for score in newScoreInfo {
            await handleNewScoreInfo(score: score)
        }
    }
    
        
}
