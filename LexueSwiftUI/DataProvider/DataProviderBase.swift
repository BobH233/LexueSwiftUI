//
//  DataProviderBase.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import Foundation

struct DataProviderInfo {
    // 英文id
    var providerId: String
    // 中文名称
    var providerName: String
    // 用途
    var description: String
    // 作者
    var author: String
}

protocol DataProvider {
    
    // 是否允许发送消息 由设置中用户自己控制
    var allowMessage: Bool { get set }
    
    // 是否允许发送通知栏消息(Notification) 由设置中用户自己控制
    var allowNotification: Bool { get set }
    
    // 消息提供者希望的默认值
    func get_default_allowMessage() -> Bool
    func get_default_allowNotification() -> Bool
    
    
    func get_priority() -> TaskPriority
    
    func info() -> DataProviderInfo
    
    // 实现刷新数据，内部推送消息的方法
    func refresh() async
}
