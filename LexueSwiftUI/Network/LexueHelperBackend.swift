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
    
    static func GetBetaURL() -> String? {
        guard let path = Bundle.main.path(forResource: "KeyInfo", ofType: "plist") else { return "" }
        let keys = NSDictionary(contentsOfFile: path)
        return keys?.value(forKey: "TestFlightUrl") as? String
    }
    
    static func GetAPIUrl() -> String {
        if GlobalVariables.shared.DEBUG_BUILD {
            return "http://192.168.8.143:3000"
        } else {
            return "https://xxxx.zendee.cn"
        }
    }
    
    enum LexueHelperBackendError: Error {
        case unknowError
        case jsonConvertError
        case networkError
    }
    
    let API_REGISTER_DEVICE_TOKEN = "\(GetAPIUrl())/api/device/register"
    
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
                print(jsonStr)
                var request = URLRequest(url: URL(string: API_REGISTER_DEVICE_TOKEN)!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = HTTPHeaders(header)
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if let retStr = String(data: data!, encoding: .utf8) {
                                print("retStr: \(retStr)")
                            }
                            continuation.resume(returning: res.response)
                        case .failure(_):
                            print("请求servicecall 失败")
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
