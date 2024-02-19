//
//  DataProviderManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import Foundation

class DataProviderManager: ObservableObject {
    static let shared = DataProviderManager()
    var dataProviders: [DataProvider] = []
    
    init() {
        dataProviders.append(LexueDataProvider())
        dataProviders.append(InfoMergingDataProvider())
        dataProviders.append(ScoreMonitorDataProvider())
        loadSettingStorage()
        // 将数据源的设置也通过icloud同步
        // 不要同步已经push的消息
        iCloudUserDefaults.shared.monitored_blacklist.append("dataprovider.HaoBIT.pushedMessage")
        iCloudUserDefaults.shared.monitored_prefix.append(contentsOf: ["dataprovider.setting.", "dataprovider.customsetting."])
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cloudUpdate(notification:)),
                                               name: iCloudUserDefaults.cloudSyncNotification,
                                               object: nil)
    }
    
    @objc internal func cloudUpdate(notification: NSNotification) {
        // 如果云端消息更新了，那本地也得实时覆盖一下
        iCloudUserDefaults.shared.disableMonitor()
        print("正在重新同步全部dataprovider的设置")
        loadSettingStorage()
        iCloudUserDefaults.shared.enableMonitor()
    }
    
    func loadKeyOrWithDefault<T>(key: String, defaultVal: T) -> T {
        if let result = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: key) as? T {
            return result
        } else {
            return defaultVal
        }
    }
    
    
    
    func loadSettingStorage() {
        // 加载默认的一些选项
        for i in 0 ..< dataProviders.count {
            let curId = dataProviders[i].info().providerId
            dataProviders[i].enabled = loadKeyOrWithDefault(key: "dataprovider.setting.\(curId).enable", defaultVal: dataProviders[i].get_default_enabled())
            dataProviders[i].allowMessage = loadKeyOrWithDefault(key: "dataprovider.setting.\(curId).allowMessage", defaultVal: dataProviders[i].get_default_allowMessage())
            dataProviders[i].allowNotification = loadKeyOrWithDefault(key: "dataprovider.setting.\(curId).allowNotification", defaultVal: dataProviders[i].get_default_allowNotification())
        }
        // 加载用户自定义的一些选项
        for i in 0 ..< dataProviders.count {
            let curId = dataProviders[i].info().providerId
            dataProviders[i].customOptions = dataProviders[i].get_custom_options()
            for (index, option) in dataProviders[i].customOptions.enumerated() {
                if option.optionType == .bool {
                    dataProviders[i].customOptions[index].optionValueBool = loadKeyOrWithDefault(key: "dataprovider.customsetting.\(curId).\(option.optionName)", defaultVal: option.optionValueBool)
                } else if option.optionType == .string {
                    dataProviders[i].customOptions[index].optionValueString = loadKeyOrWithDefault(key: "dataprovider.customsetting.\(curId).\(option.optionName)", defaultVal: option.optionValueString)
                }
            }
        }
    }
    
    func saveProviderCustomSettings(providerId: String, newOptionValue: [ProviderCustomOption]) {
        for i in 0 ..< dataProviders.count {
            let curId = dataProviders[i].info().providerId
            if curId == providerId {
                dataProviders[i].customOptions = newOptionValue
                for option in newOptionValue {
                    if option.optionType == .bool {
                        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(option.optionValueBool, forKey: "dataprovider.customsetting.\(curId).\(option.optionName)")
                    } else if option.optionType == .string {
                        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(option.optionValueString, forKey: "dataprovider.customsetting.\(curId).\(option.optionName)")
                    }
                }
                break
            }
        }
        iCloudUserDefaults.shared.SyncSome(prefix: ["dataprovider.setting.", "dataprovider.customsetting."])
    }
    
    func setProviderSetting<T>(attribute: String, providerId: String, val: T) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(val, forKey: "dataprovider.setting.\(providerId).\(attribute)")
        loadSettingStorage()
    }
    
    func getProviderSetting<T>(attribute: String, providerId: String) -> T? {
        return UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.object(forKey: "dataprovider.setting.\(providerId).\(attribute)") as? T
    }
    
    var lastRefresh: Double = 0
    
    // 分发apns端发来的消息
    func DispatchApnsMessage(providerId: String, data: Any) async {
        for provider in dataProviders {
            if provider.info().providerId == providerId {
                provider.handleApns(data: data)
            }
        }
        for var provider in dataProviders {
            if provider.allowMessage {
                for msg in provider.msgRequestList {
                    await DataController.shared.container.performBackgroundTask { (bgContext) in
                        MessageManager.shared.PushMessageWithContactCreation(senderUid: msg.senderUid, contactOriginNameIfMissing: msg.contactOriginNameIfMissing, contactTypeIfMissing: msg.contactTypeIfMissing, msgBody: msg.msgBody, date: msg.date, notify: provider.allowNotification, messageHash: msg.msgHash, context: bgContext)
                    }
                }
            }
            provider.msgRequestList.removeAll()
        }
    }
    
    func FindProvider(providerId: String) -> DataProvider? {
        for registered_provider in dataProviders {
            if registered_provider.providerIdForEach == providerId {
                return registered_provider
            }
        }
        return nil
    }
    
    func DoRefreshAll(param: [String: Any] = [:], manually: Bool = false) async {
        let currentTimeStamp = Date.now.timeIntervalSince1970
        if !manually && currentTimeStamp - lastRefresh < 60 {
            print("自动刷新太频繁，自动忽略")
            return
        }
        lastRefresh = currentTimeStamp
        await withTaskGroup(of: Void.self) { group in
            for provider in dataProviders {
                if provider.enabled {
                    group.addTask(priority: provider.get_priority()) {
                        await provider.refresh(param: param, manually: manually)
                    }
                }
            }
        }
        for var provider in dataProviders {
            if provider.allowMessage {
                for msg in provider.msgRequestList {
                    await DataController.shared.container.performBackgroundTask { (bgContext) in
                        MessageManager.shared.PushMessageWithContactCreation(senderUid: msg.senderUid, contactOriginNameIfMissing: msg.contactOriginNameIfMissing, contactTypeIfMissing: msg.contactTypeIfMissing, msgBody: msg.msgBody, date: msg.date, notify: provider.allowNotification, messageHash: msg.msgHash, context: bgContext)
                    }
                }
            }
            provider.msgRequestList.removeAll()
        }
    }
}
