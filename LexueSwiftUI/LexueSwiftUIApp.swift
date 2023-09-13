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
    @StateObject private var dataController = DataController()
    @ObservedObject var settings = SettingStorage.shared
    @Environment(\.scenePhase) private var scenePhase
    
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
                    .environment(\.managedObjectContext,
                                  dataController.container.viewContext)
                    .environment(\.locale, Locale.init(identifier: "zh-CN"))
            }else{
                ContentView()
                    .environment(\.managedObjectContext,
                                  dataController.container.viewContext)
                    .environment(\.locale, Locale.init(identifier: "zh-CN"))
                    .preferredColorScheme(getPreferredColorScheme())
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                AppStatusManager.shared.OnAppGoToForeground()
            case .background:
                AppStatusManager.shared.OnAppGoToBackground()
            case .inactive:
                AppStatusManager.shared.OnAppInactive()
            @unknown default:
                print("Unknow phase...")
            }
        }
    }
}
