//
//  SettingStorage.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation

class SettingStorage: ObservableObject {
    static let shared = SettingStorage()
    
    // 应用颜色选项
    @Published var preferColorScheme: Int {
        didSet {
            UserDefaults.standard.set(preferColorScheme, forKey: "setting.preferColorScheme")
        }
    }
    
    private init() {
        if let stored = UserDefaults.standard.value(forKey: "setting.preferColorScheme") as? Int {
            preferColorScheme = stored
        } else {
            preferColorScheme = 2
        }
    }
}
