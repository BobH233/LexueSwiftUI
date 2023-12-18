//
//  LexueHelperBackend.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/17.
//

import Foundation
import Alamofire

class LexueHelperBackend {
    static let shared = LexueHelperBackend()
    
    init() {
        if let stored = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "backend.lastFetchNotificationHash") as? String {
            lastFetchNotificationHash = stored
        } else {
            lastFetchNotificationHash = ""
        }
    }
    
    static func GetBetaURL() -> String? {
        guard let path = Bundle.main.path(forResource: "KeyInfo", ofType: "plist") else { return "" }
        let keys = NSDictionary(contentsOfFile: path)
        return keys?.value(forKey: "TestFlightUrl") as? String
    }
    
    static func GetAPIUrl() -> String {
        if GlobalVariables.shared.DEBUG_BUILD {
            return "http://192.168.8.143:3000"
        } else {
            return "https://api.bit-helper.cn"
        }
    }
    
    enum LexueHelperBackendError: Error {
        case unknowError
        case jsonConvertError
        case networkError
    }
    
    var lastFetchNotificationHash: String {
        didSet {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(lastFetchNotificationHash, forKey: "backend.lastFetchNotificationHash")
        }
    }
    
    let API_REGISTER_DEVICE_TOKEN = "\(GetAPIUrl())/api/device/register"
    let API_FETCH_NOTICE = "\(GetAPIUrl())/api/notice/fetch"
    let API_FETCH_APP_NOTIFICATIONS = "\(GetAPIUrl())/api/notification/get"
    let API_CHECK_IS_ADMIN = "\(GetAPIUrl())/api/device/isadmin"
    
    struct PackageWithSignature {
        var cmdName: String = ""
        var packageUUID: String = UUID().uuidString
        var userId: String = ""
        var timestamp: String = ""
        func CalcSignature() -> String {
            var salt = ""
            guard let path = Bundle.main.path(forResource: "KeyInfo", ofType: "plist") else { return "" }
            if let keys = NSDictionary(contentsOfFile: path), let salt = keys.value(forKey: "SignatureSalt") as? String {
                let hash_string = "\(cmdName)_^\(userId)^&\(packageUUID)*time\(timestamp)salt*=\(salt)"
                return hash_string.sha256
            } else {
                return ""
            }
        }
    }
    
    // app的公告，包括更新内容之类的等等
    struct AppNotification {
        // 公告的id
        var notificationId: Int = 0
        // 发出的时间戳
        var timestamp: String = ""
        // 通知的markdown格式内容
        var markdownContent: String = ""
        // 是否置顶
        var pinned: Bool = false
        // 是否是弹出显示类消息
        var isPopupNotification: Bool = false
        // 只在某些版本的app上显示, 如果是空则默认在所有版本都显示
        var appVersionLimit: [String] = []
        // 是否被隐藏，不为0的话，就不显示
        var isHide: Int = 0
        func GetDate() -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateFormatter.date(from: timestamp) {
                let newDateFormatter = DateFormatter()
                newDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                newDateFormatter.timeZone = TimeZone(identifier: "UTF+8")

                let dateInUTF8TimeZoneString = newDateFormatter.string(from: date)
                
                if let dateInUTF8TimeZone = newDateFormatter.date(from: dateInUTF8TimeZoneString) {
                    return dateInUTF8TimeZone
                } else {
                    return Date()
                }
            }
            return Date()
        }
        func ShouldDisplayInCurrentApp() -> Bool {
            if appVersionLimit.count == 0 {
                return true
            }
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return appVersionLimit.contains(version)
            }
            return false
        }
    }
    
    func FetchAppNotifications(onlyThisVersion: Bool = true) async -> [AppNotification] {
        let header: [String: String] = [
            "Content-Type": "application/json"
        ]
        do {
            var request = URLRequest(url: URL(string: API_FETCH_APP_NOTIFICATIONS)!)
            request.cachePolicy = .reloadIgnoringCacheData
            request.httpMethod = HTTPMethod.get.rawValue
            request.headers = HTTPHeaders(header)
            let ret = await withCheckedContinuation { continuation in
                AF.request(request).response { res in
                    switch res.result {
                    case .success(let data):
                        if let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [[String: Any]] {
                            continuation.resume(returning: json)
                        } else {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [[String: Any]]())
                        }
                    case .failure(let error):
                        print("请求 后端 失败")
                        print(error)
                        continuation.resume(returning: [[String: Any]]())
                    }
                }
            }
            var retNotifications = [AppNotification]()
            for notification in ret {
                var current = AppNotification()
                if let id = notification["id"] as? Int {
                    current.notificationId = id
                }
                if let timestamp = notification["timestamp"] as? String {
                    current.timestamp = timestamp
                }
                if let markdownContent = notification["markdownContent"] as? String {
                    current.markdownContent = markdownContent
                }
                if let pinned = notification["pinned"] as? Bool {
                    current.pinned = pinned
                }
                if let isPopupNotification = notification["isPopupNotification"] as? Bool {
                    current.isPopupNotification = isPopupNotification
                }
                if let versionLimit = notification["appVersionLimit"] as? String, let data = versionLimit.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                    current.appVersionLimit = json
                }
                if let isHide = notification["isHide"] as? Int {
                    current.isHide = isHide
                }
                if current.ShouldDisplayInCurrentApp() || !onlyThisVersion {
                    retNotifications.append(current)
                }
            }
            return retNotifications
        } catch {
            print("转换为 JSON 数据时发生错误: \(error)")
            return []
        }
    }
    
    // 获取当前用户是否在后台管理员列表中
    func GetIsAdmin(userId: String) async -> Bool {
        var packageHeader = PackageWithSignature()
        packageHeader.cmdName = "IsAdmin"
        packageHeader.userId = userId
        packageHeader.timestamp = "\(Int(Date.now.timeIntervalSince1970))"
        let Payload: [String: Any] = [
            "cmdName": packageHeader.cmdName,
            "UUID": packageHeader.packageUUID,
            "userId": userId,
            "signature": packageHeader.CalcSignature(),
            "timestamp": packageHeader.timestamp,
            "data": []
        ]
        let header: [String: String] = [
            "Content-Type": "application/json"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: Payload, options: [])
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                print(jsonStr)
                var request = URLRequest(url: URL(string: API_CHECK_IS_ADMIN)!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = HTTPHeaders(header)
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
                                continuation.resume(returning: json)
                            } else {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                            }
                        case .failure(_):
                            print("请求 后端 失败")
                            continuation.resume(returning: [String: Any]())
                        }
                    }
                }
                if let isadmin = ret["isAdmin"] as? Bool {
                    return isadmin
                } else {
                    return false
                }
            } else {
                print("转换为 JSON 数据时发生错误")
                return false
            }
        } catch {
            print("转换为 JSON 数据时发生错误: \(error)")
            return false
        }
    }
    
    // 请求i乐学助手维护的HaoBIT消息
    func FetchHaoBITMessage(userId: String) async -> [HaoBIT.Notice] {
        print("lastFetchNotificationHash: \(lastFetchNotificationHash)")
        var packageHeader = PackageWithSignature()
        packageHeader.cmdName = "FetchHaoBIT"
        packageHeader.userId = userId
        packageHeader.timestamp = "\(Int(Date.now.timeIntervalSince1970))"
        let Payload: [String: Any] = [
            "cmdName": packageHeader.cmdName,
            "UUID": packageHeader.packageUUID,
            "userId": userId,
            "signature": packageHeader.CalcSignature(),
            "timestamp": packageHeader.timestamp,
            "data": [
                "afterHash": lastFetchNotificationHash
            ]
        ]
        let header: [String: String] = [
            "Content-Type": "application/json"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: Payload, options: [])
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                print(jsonStr)
                var request = URLRequest(url: URL(string: API_FETCH_NOTICE)!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = HTTPHeaders(header)
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] {
                                continuation.resume(returning: json)
                            } else {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                            }
                        case .failure(_):
                            print("请求 后端 失败")
                            continuation.resume(returning: [String: Any]())
                        }
                    }
                }
                var retNotices = [HaoBIT.Notice]()
                if let latestHash = ret["latestHash"] as? String {
                    print("latestHash: \(latestHash)")
                    lastFetchNotificationHash = latestHash
                }
                if let data = ret["data"] as? [[String: Any]] {
                    for notice in data {
                        var currentNotice = HaoBIT.Notice()
                        currentNotice.link = notice["link"] as? String
                        currentNotice.title = notice["title"] as? String
                        currentNotice.source = notice["source"] as? String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        if let dateString = notice["date"] as? String, let date = dateFormatter.date(from: dateString) {
                            currentNotice.date = date
                        }
                        retNotices.append(currentNotice)
                    }
                    print(retNotices)
                    return retNotices
                } else {
                    return []
                }
            } else {
                print("转换为 JSON 数据时发生错误")
                return []
            }
        } catch {
            print("转换为 JSON 数据时发生错误: \(error)")
            return []
        }
    }
    
    // 向 i乐学助手注册消息推送服务
    func RegisterDeviceTokenForServer(userId: String, deviceToken: String) async -> Result<String, LexueHelperBackendError> {
        var packageHeader = PackageWithSignature()
        packageHeader.cmdName = "RegisterDeviceToken"
        packageHeader.userId = userId
        packageHeader.timestamp = "\(Int(Date.now.timeIntervalSince1970))"
        let Payload: [String: Any] = [
            "cmdName": packageHeader.cmdName,
            "UUID": packageHeader.packageUUID,
            "userId": userId,
            "signature": packageHeader.CalcSignature(),
            "timestamp": packageHeader.timestamp,
            "data": [
                "deviceToken": deviceToken
            ]
        ]
        let header: [String: String] = [
            "Content-Type": "application/json"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: Payload, options: [])
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                // print(jsonStr)
                var request = URLRequest(url: URL(string: API_REGISTER_DEVICE_TOKEN)!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = HTTPHeaders(header)
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            continuation.resume(returning: res.response)
                        case .failure(_):
                            print("请求后端 失败")
                            continuation.resume(returning: res.response)
                        }
                    }
                }
                if ret != nil && ret!.statusCode == 200 {
                    return .success("success")
                } else {
                    return .failure(.networkError)
                }
            } else {
                print("转换为 JSON 数据时发生错误")
                return .failure(.jsonConvertError)
            }
        } catch {
            print("转换为 JSON 数据时发生错误: \(error)")
            return .failure(.jsonConvertError)
        }
    }
}
