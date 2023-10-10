//
//  Webvpn.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/9.
//

import Foundation
import Alamofire

/**
        提供校内外同时访问webvpn的能力
        用户无论在何处都可以随时通过webvpn访问内网服务
        登录过程是无感的
        换 BIT101 查成绩了
 */
class Webvpn {
    static let shared = Webvpn()
    
    let API_WEBVPN_TICK = "https://login.bit.edu.cn/authserver/login?service=https://webvpn.bit.edu.cn/login?cas_login=true"
    
    // 一个直接的反向代理，解决校内无法访问webvpn的问题...
    // 之前尝试过直接用 webvpn 解析出来的ip进行访问，但是有ssl验证问题死活解决不了，没办法...
    // TODO: 记得修改用户协议告知用户
    let WEBVPN_INDEX = "https://lexue.zendee.cn/"
    
    let BIT101_WEBVPN_INIT = "https://bit101.flwfdd.xyz/user/webvpn_verify_init"
    let BIT101_WEBVPN_VERIFY = "https://bit101.flwfdd.xyz/user/webvpn_verify"
    
    let WEBVPN_ORIGIN_DOMAIN = "webvpn.bit.edu.cn"
    let PROXY_WEBVPN_DOMAIN = "lexue.zendee.cn"

    
    let headers = [
        "User-Agent": "LexueHelper"
    ]
    
    let login_headers = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    
    struct WebvpnContext {
        var wengine_vpn_ticketwebvpn_bit_edu_cn: String = ""
    }
    
    enum WebvpnError: Error {
        case NetworkError
        case UnknowError
        case CannotGetTicket
        case NeedCaptcha
        case JsonConvertError
    }
    
    func GetWebvpnContext(username: String, password: String) async -> Result<WebvpnContext, WebvpnError> {
        var ret_context = WebvpnContext()
        var init_param = [
            "sid": username
        ]
        let header_with_json_type = [
            "Content-Type": "application/json"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: init_param, options: [])
            if String(data: jsonData, encoding: .utf8) != nil {
                var request = URLRequest(url: URL(string: BIT101_WEBVPN_INIT)!)
                request.headers = HTTPHeaders(header_with_json_type)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                continuation.resume(returning: json)
                            } else {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                            }
                        case .failure(_):
                            print("请求 bit101_init 失败")
                            continuation.resume(returning: [String: Any]())
                        }
                    }
                }
                guard let cookie = ret["cookie"] as? String else {
                    return .failure(.NetworkError)
                }
                guard let captcha = ret["captcha"] as? String else {
                    return .failure(.NetworkError)
                }
                guard let salt = ret["salt"] as? String else {
                    return .failure(.NetworkError)
                }
                guard let execution = ret["execution"] as? String else {
                    return .failure(.NetworkError)
                }
                if captcha != "" {
                    return .failure(.NeedCaptcha)
                }
                let encryptedPassword = BITLogin.shared.encryptPassword(pwd0: password, key: salt)
                let param2 = [
                    "sid": username,
                    "password": encryptedPassword,
                    "execution": execution,
                    "cookie": cookie
                ]
                let jsonData2 = try JSONSerialization.data(withJSONObject: param2, options: [])
                guard let t = String(data: jsonData2, encoding: .utf8) else {
                    return .failure(.JsonConvertError)
                }
                var request2 = URLRequest(url: URL(string: BIT101_WEBVPN_VERIFY)!)
                request2.headers = HTTPHeaders(header_with_json_type)
                request2.cachePolicy = .reloadIgnoringCacheData
                request2.httpMethod = HTTPMethod.post.rawValue
                request2.httpBody = jsonData2
                let status_code = await withCheckedContinuation { continuation in
                    AF.request(request2).response { res in
                        switch res.result {
                        case .success(let data):
                            if let data_str = String(data: data!, encoding: .utf8) {
                                print(data_str)
                            }
                            continuation.resume(returning: res.response?.statusCode ?? -1)
                        case .failure(_):
                            print("请求 bit101_verify 失败")
                            continuation.resume(returning: -1)
                        }
                    }
                }
                print("status_code: \(status_code)")
                if status_code != 200 {
                    return .failure(.UnknowError)
                }
                ret_context.wengine_vpn_ticketwebvpn_bit_edu_cn = get_cookie_key(cookie, "wengine_vpn_ticketwebvpn_bit_edu_cn")
                return .success(ret_context)
            } else {
                return .failure(.JsonConvertError)
            }
        } catch {
            return .failure(.UnknowError)
        }
    }
    
}
