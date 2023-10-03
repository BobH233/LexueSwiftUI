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
    // 禁止横屏
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
// Conform to UNUserNotificationCenterDelegate to show local notification in foreground
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let cmd = userInfo["cmd"] as? String {
            if cmd == "contactMessage" && GlobalVariables.shared.handleNotificationMsg != nil{
                GlobalVariables.shared.handleNotificationMsg!(userInfo)
            }
        }
        print(userInfo)
        completionHandler()
    }
}

@main
struct LexueSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.colorScheme) var sysColorScheme
    @StateObject private var dataController = DataController.shared
    @ObservedObject var settings = SettingStorage.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "cn.bobh.LexueSwiftUI.BGRefresh", using: DispatchQueue.main) { task in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 设置日期格式

            let currentDate = Date()
            let formattedDate = dateFormatter.string(from: currentDate)
            print("In the background func!")
            task.expirationHandler = {
                LocalNotificationManager.shared.PushNotification(title: "\(formattedDate) 成功调用", body: "我要过期了!!!", userInfo: ["123":"1234"], image:GlobalVariables.shared.userAvatarUIImage, interval: 0.1)
                task.setTaskCompleted(success: false)
            }
            Task {
                let res = await LexueAPI.shared.GetSelfUserInfo(GlobalVariables.shared.cur_lexue_context)
                switch res {
                case .success(let userInfo):
                    LocalNotificationManager.shared.PushNotification(title: "\(formattedDate) 成功调用", body: "\(userInfo.onlineUsers)", userInfo: ["123":"1234"], image:GlobalVariables.shared.userAvatarUIImage, interval: 0.1)
                case .failure(let error):
                    LocalNotificationManager.shared.PushNotification(title: "\(formattedDate) 失败调用", body: "\(error.localizedDescription)", userInfo: ["123":"1234"], image:GlobalVariables.shared.userAvatarUIImage, interval: 0.1)
                }
                AppStatusManager.scheduleAppBackgroundRefresh()
                DispatchQueue.main.async {
                    task.setTaskCompleted(success: true)
                }
            }
        }
    }
    
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
//        .backgroundTask(.appRefresh("cn.bobh.LexueSwiftUI.BGRefresh")) {
//            print("background task!")
//            LocalNotificationManager.shared.PushNotification(title: "1234", body: "test", userInfo: ["123":"1234"], image:GlobalVariables.shared.userAvatarUIImage, interval: 0.1)
//            AppStatusManager.scheduleAppBackgroundRefresh()
//        }
    }
}
