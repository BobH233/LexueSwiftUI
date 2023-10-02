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
    var usage: String
    // 作者
    var author: String
}

protocol DataProvider {
    
    func get_priority() -> TaskPriority
    
    func info() -> DataProviderInfo
    
    // 实现刷新数据，内部推送消息的方法
    func refresh() async
}
