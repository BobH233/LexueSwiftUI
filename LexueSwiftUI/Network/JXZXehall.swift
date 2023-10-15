//
//  JXZXehall.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/15.
//

import Foundation
import Alamofire

// 教学中心电子大厅，用于查询考试安排相关
class JXZXehall {
    static let shared = JXZXehall()
    
    // 用手机版获取Cookie方便一些
    let JXZX_INDEX = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do"
    let API_JXZX_TICK = "https://login.bit.edu.cn/authserver/login?service=https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do#/"
    let API_JXZX_APP_INDEX = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/mobilepub/res/sentry/wdksapMobile.do"
    // post
    let API_JXZX_APP_CONFIG = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/mobilepub/getAppConfig/wdksapMobile.do"
    
    let bit_login_header = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    let jxzx_header = [
        "Host": "jxzxehallapp.bit.edu.cn",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    
    struct JXZXContext {
        var GS_SESSIONID: String = ""
        var _WEU: String = ""
    }
    
    enum JXZXError: Error {
        case NetworkError
        case UnknowError
        case CannotGetTicket
        case JsonConvertError
    }
    
    private func GetTicketLoginUrl(loginnedContext: BITLogin.LoginSuccessContext) async -> String {
        var cur_headers = HTTPHeaders(bit_login_header)
        cur_headers.add(name: "Cookie", value: "CASTGC=\(loginnedContext.CASTGC)")
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_TICK, method: .get, headers: cur_headers)
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    switch response.result {
                    case .success(_):
                        if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                            continuation.resume(returning: login_url)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(_):
                        continuation.resume(returning: "")
                    }
                }
        }
    }
    
    private func GetRealWEU(fakeWEU: String, GS_SESSIONID: String, origin: Bool, url: String, method: HTTPMethod) async -> String {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(GS_SESSIONID); _WEU=\(fakeWEU);")
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        if origin {
            cur_headers.add(name: "Origin", value: "https://jxzxehallapp.bit.edu.cn")
        }
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(url, method: method, headers: cur_headers)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    switch response.result {
                    case .success(_):
                        if let ret_headers = response.response?.allHeaderFields as? [String: String] {
                            if let cookie = ret_headers["Set-Cookie"] {
                                continuation.resume(returning: get_cookie_key(cookie, "_WEU"))
                            } else {
                                continuation.resume(returning: "")
                            }
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(let error):
                        print(error)
                        continuation.resume(returning: "")
                    }
                }
        }
    }
    
    func GetJXZXContext(loginnedContext: BITLogin.LoginSuccessContext) async -> Result<JXZXContext, JXZXError> {
        let ticketLoginUrl = await GetTicketLoginUrl(loginnedContext: loginnedContext)
        if ticketLoginUrl.isEmpty {
            return .failure(.CannotGetTicket)
        }
        let first_cookie = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(ticketLoginUrl, method: .get)
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response1 in
                    switch response1.result {
                    case .success(_):
                        if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: cookie)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(_):
                        continuation.resume(returning: "")
                    }
                }
        }
        if first_cookie.isEmpty {
            return .failure(.CannotGetTicket)
        }
        var retContext = JXZXContext()
        retContext.GS_SESSIONID = get_cookie_key(first_cookie, "GS_SESSIONID")
        var second_cookie = await withCheckedContinuation { continuation in
            var cur_headers = HTTPHeaders(jxzx_header)
            cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(retContext.GS_SESSIONID)")
            AF.requestWithoutCache(JXZX_INDEX, method: .get, headers: cur_headers)
                .redirect(using: Redirector.doNotFollow)
                .response { response1 in
                    switch response1.result {
                    case .success(_):
                        if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: cookie)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(let error):
                        print(error     )
                        continuation.resume(returning: "")
                    }
                }
        }
        if second_cookie.isEmpty {
            return .failure(.CannotGetTicket)
        }
        // 只截取第二个_WEU
        if let range = second_cookie.range(of: "_WEU=") {
            second_cookie.replaceSubrange(range, with: "")
        }
        var tmpWEU = get_cookie_key(second_cookie, "_WEU")
        retContext._WEU = await GetRealWEU(fakeWEU: tmpWEU, GS_SESSIONID: retContext.GS_SESSIONID, origin: false, url: API_JXZX_APP_INDEX, method: .get)
        retContext._WEU = await GetRealWEU(fakeWEU: retContext._WEU, GS_SESSIONID: retContext.GS_SESSIONID, origin: true, url: API_JXZX_APP_CONFIG, method: .post)
        return .success(retContext)
    }
}
