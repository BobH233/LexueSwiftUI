//
//  UMengManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import Foundation

class UMengManager {
    static let shared = UMengManager()
    
    
    func GetUMengAppKey() -> String {
        guard let path = Bundle.main.path(forResource: "KeyInfo", ofType: "plist") else { return "" }
        let keys = NSDictionary(contentsOfFile: path)
        if let umengapp = keys?.value(forKey: "UmengApp") as? [String: Any], let ret = umengapp["app_key"] as? String {
            return ret
        } else {
            return ""
        }
    }
    
    func AppStartLogic() {
        print("UMeng AppStartLogic")
        UMCommonLogSwift.setUpUMCommonLogManager()
        UMCommonSwift.setLogEnabled(bFlag: false)
        let app_key = GetUMengAppKey()
        // TODO: 删除这个print
        // print("app_key: \(app_key)")
        UMCommonSwift.initWithAppkey(appKey: app_key, channel: "App Store")
    }
}
