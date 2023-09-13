//
//  LexueAPI.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/12.
//

import Foundation
import Alamofire
import SwiftSoup

struct LexueContext {
    var MoodleSession: String = ""
}

class LexueAPI {
    static let shared = LexueAPI()
    
    let API_LEXUE_TICK = "https://login.bit.edu.cn/authserver/login?service=https://lexue.bit.edu.cn/login/index.php"
    
    let headers = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    enum LexueLoginError: Error {
        case networkError
        case noLocationHeader
    }
    
    func GetLexueContext(_ loginnedContext: LoginSuccessContext, completion: @escaping (Result<LexueContext, LexueLoginError>) -> Void) {
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: "CASTGC=\(loginnedContext.CASTGC)")
        AF.requestWithoutCache(API_LEXUE_TICK, method: .get, headers: cur_headers)
            .validate(statusCode: 300..<500)
            .redirect(using: Redirector.doNotFollow)
            .response { response in
                switch response.result {
                case .success( _):
                    if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                        print("login_url: \(login_url)")
                        AF.requestWithoutCache(login_url, method: .get)
                            .validate(statusCode: 300..<500)
                            .redirect(using: Redirector.doNotFollow)
                            .response { response1 in
                                switch response1.result {
                                case .success(_):
                                    if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                                        var ret = LexueContext()
                                        ret.MoodleSession = get_cookie_key(cookie, "MoodleSession")
                                        completion(.success(ret))
                                        print(ret)
                                    }
                                case .failure(_):
                                    print("登录lexue 失败")
                                    completion(.failure(LexueLoginError.networkError))
                                }
                            }
                    } else {
                        completion(.failure(LexueLoginError.noLocationHeader))
                    }
                case .failure(_):
                    print("GetLexueContext 失败")
                    completion(.failure(LexueLoginError.networkError))
                }
                
            }
    }
}
