//
//  LexueSwiftUIApp.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import BackgroundTasks

// https://ishtiz.com/swift/how-to-show-local-notification-when-the-app-is-foreground
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Show local notification in foreground
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}
// Conform to UNUserNotificationCenterDelegate to show local notification in foreground
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
}

@main
struct LexueSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
