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
