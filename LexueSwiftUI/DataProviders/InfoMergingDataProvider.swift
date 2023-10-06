//
//  InfoMergingDataProvider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/6.
//

import Foundation

/**
        校内消息聚合，主要是一些教务部的通知等等
 */
class InfoMergingDataProvider: DataProvider {
    
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
        return [
            .init(optionName: "test_prop1", displayName: "测试属性1", optionType: .bool, optionValueBool: false),
            .init(optionName: "test_prop2", displayName:"测试属性2", optionType: .bool, optionValueBool: true),
            .init(optionName: "test_prop3", displayName:"测试属性3", optionType: .string, optionValueString: "allala")
        ]
    }
    
    func get_priority() -> TaskPriority {
        return .medium
    }
    
    var providerIdForEach: String {
        return "provider.info_merging"
    }
    
    func info() -> DataProviderInfo {
        return DataProviderInfo(providerId: "provider.info_merging", providerName: "消息聚合服务", description: "聚合教务处、各学院发布的消息，并发送通知", author: "BobH")
    }
    
    func refresh(param: [String : Any]) async {
        return
    }
    
    
}
