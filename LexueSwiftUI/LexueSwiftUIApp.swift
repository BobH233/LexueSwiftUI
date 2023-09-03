//
//  LexueSwiftUIApp.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

@main
struct LexueSwiftUIApp: App {
    @Environment(\.colorScheme) var sysColorScheme
    @ObservedObject var settings = SettingStorage.shared
    func getPreferredColorScheme() -> ColorScheme {
        switch settings.preferColorScheme {
        case 0:
            return .dark
        case 1:
            return .light
        case 2:
            return sysColorScheme
        default:
            return .light
        }
    }
    var body: some Scene {
        WindowGroup {
            if settings.preferColorScheme == 2 {
                ContentView()
            }else{
                ContentView().preferredColorScheme(getPreferredColorScheme())
            }
            
        }
    }
}
