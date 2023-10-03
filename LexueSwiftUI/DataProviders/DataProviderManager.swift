//
//  DataProviderManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import Foundation

class DataProviderManager {
    static let shared = DataProviderManager()
    var dataProviders: [DataProvider] = []
    
    init() {
        dataProviders.append(LexueDataProvider())
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
        for i in 0 ..< dataProviders.count {
            let curId = dataProviders[i].info().providerId
            dataProviders[i].enabled = loadKeyOrWithDefault(key: "dataprovider.setting.\(curId).enable", defaultVal: dataProviders[i].get_default_enabled())
            dataProviders[i].allowMessage = loadKeyOrWithDefault(key: "dataprovider.setting.\(curId).allowMessage", defaultVal: dataProviders[i].get_default_allowMessage())
            dataProviders[i].allowNotification = loadKeyOrWithDefault(key: "dataprovider.setting.\(curId).allowNotification", defaultVal: dataProviders[i].get_default_allowNotification())
        }
    }
    
    func setProviderSetting<T>(attribute: String, providerId: String, val: T) {
        UserDefaults.standard.set(val, forKey: "dataprovider.setting.\(providerId).\(attribute)")
        loadSettingStorage()
    }
    
    func DoRefreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            for provider in dataProviders {
                group.addTask(priority: provider.get_priority()) {
                    await provider.refresh()
                }
            }
        }
    }
}
