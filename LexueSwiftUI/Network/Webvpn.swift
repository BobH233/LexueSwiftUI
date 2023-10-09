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
 */
class Webvpn {
    static let shared = Webvpn()
    
    let API_WEBVPN_TICK = "https://login.bit.edu.cn/authserver/login?service=https://webvpn.bit.edu.cn/login?cas_login=true"
    
    // 一个直接的反向代理，解决校内无法访问webvpn的问题...
    // 之前尝试过直接用 webvpn 解析出来的ip进行访问，但是有ssl验证问题死活解决不了，没办法...
    // TODO: 记得修改用户协议告知用户
    let WEBVPN_INDEX = "https://lexue.zendee.cn/"
    
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
    }
    private func GetLexueLoginTicketUrl(_ loginnedContext: BITLogin.LoginSuccessContext) async -> Result<String, WebvpnError> {
        var cur_headers = HTTPHeaders(login_headers)
        cur_headers.add(name: "Cookie", value: "CASTGC=\(loginnedContext.CASTGC)")
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_WEBVPN_TICK, method: .get, headers: cur_headers)
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    switch response.result {
                    case .success( _):
                        if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                            continuation.resume(returning: .success(login_url))
                        } else {
                            continuation.resume(returning: .failure(.CannotGetTicket))
                        }
                    case .failure(_):
                        print("webvpn GetLexueContext 失败")
                        continuation.resume(returning: .failure(.CannotGetTicket))
                    }
                    
                }
        }
    }
    func GetWebvpnContext(_ loginnedContext: BITLogin.LoginSuccessContext) async -> Result<WebvpnContext, WebvpnError> {
        var ret = WebvpnContext()
        
        // 先获得一个cookie
        let cookie = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(WEBVPN_INDEX, method: .get, headers: HTTPHeaders(headers))
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    switch response.result {
                    case .success(_):
                        if let ret_headers = response.response?.allHeaderFields as? [String: String], let setCookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: get_cookie_key(setCookie, "wengine_vpn_ticketwebvpn_bit_edu_cn"))
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(let error):
                        print(error)
                        continuation.resume(returning: "")
                    }
                }
        }
        if cookie == "" {
            print("获取webvpn cookie 失败")
            return .failure(.NetworkError)
        }
        ret.wengine_vpn_ticketwebvpn_bit_edu_cn = cookie
        let ticketRes = await GetLexueLoginTicketUrl(loginnedContext)
        var redirectLoginUrl:String = ""
        switch ticketRes {
        case .success(let redirectUrl):
            redirectLoginUrl = redirectUrl
        case .failure(let error):
            return .failure(error)
        }
        redirectLoginUrl = redirectLoginUrl.replacingOccurrences(of: WEBVPN_ORIGIN_DOMAIN, with: PROXY_WEBVPN_DOMAIN)
        print("redirectURL: \(redirectLoginUrl)")
        return .success(ret)
    }
    
}
