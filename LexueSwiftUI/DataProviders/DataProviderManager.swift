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
        if let result = UserDefaults.standard.value(forKey: key) as? T {
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
            for var option in dataProviders[i].customOptions {
                if option.optionType == .bool {
                    option.optionValueBool = loadKeyOrWithDefault(key: "dataprovider.customsetting.\(curId).\(option.optionName)", defaultVal: option.optionValueBool)
                } else if option.optionType == .string {
                    option.optionValueString = loadKeyOrWithDefault(key: "dataprovider.customsetting.\(curId).\(option.optionName)", defaultVal: option.optionValueString)
                }
            }
        }
    }
    
    func saveProviderCustomSettings(providerId: String, newOptionValue: [ProviderCustomOption]) {
        
    }
    
    func setProviderSetting<T>(attribute: String, providerId: String, val: T) {
        UserDefaults.standard.set(val, forKey: "dataprovider.setting.\(providerId).\(attribute)")
        loadSettingStorage()
    }
    

    
    func DoRefreshAll(param: [String: Any] = [:]) async {
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
