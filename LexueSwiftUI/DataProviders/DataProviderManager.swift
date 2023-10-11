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
        loadSettingStorage()
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
    }
    
    func setProviderSetting<T>(attribute: String, providerId: String, val: T) {
        UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(val, forKey: "dataprovider.setting.\(providerId).\(attribute)")
        loadSettingStorage()
    }
    
    var lastRefresh: Double = 0
    
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
                        await provider.refresh(param: param)
                    }
                }
            }
        }
        for var provider in dataProviders {
            if provider.allowMessage {
                for msg in provider.msgRequestList {
                    await DataController.shared.container.performBackgroundTask { (bgContext) in
                        MessageManager.shared.PushMessageWithContactCreation(senderUid: msg.senderUid, contactOriginNameIfMissing: msg.contactOriginNameIfMissing, contactTypeIfMissing: msg.contactTypeIfMissing, msgBody: msg.msgBody, date: msg.date, notify: provider.allowNotification, context: bgContext)
                    }
                }
            }
            provider.msgRequestList.removeAll()
        }
    }
}
