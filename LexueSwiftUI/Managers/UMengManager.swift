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
        var keyName = ""
        if GlobalVariables.shared.DEBUG_BUILD {
            keyName = "app_key_dev"
        } else {
            keyName = "app_key_release"
        }
        if let umengapp = keys?.value(forKey: "UmengApp") as? [String: Any], let ret = umengapp[keyName] as? String {
            return ret
        } else {
            fatalError("无法载入友盟key")
        }
    }
    
    func AppStartLogic() {
        print("UMeng AppStartLogic")
        UMCommonLogSwift.setUpUMCommonLogManager()
        UMCommonSwift.setLogEnabled(bFlag: false)
        let app_key = GetUMengAppKey()
        UMCommonSwift.initWithAppkey(appKey: app_key, channel: GlobalVariables.shared.CURRENT_CHANNEL)
    }
}
